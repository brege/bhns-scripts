#!/bin/bash

# usage:
# ./domain-info.sh

set -e
set -u
shopt -s nullglob

lev="Lev1"
basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_SettleDisk"

for run in $sdbase ; do
	cd $run

	datfile="${run}/JoinedLev1/GrDomainInfo.dat"

	#echo `date`
	echo "Descending into " $run
	echo "#[1] Time" 1> $datfile # overwrites an existing file with this one line
	echo "#[2] Number of Cores" 1>> $datfile # appends to it hereafter
	echo "#[3] Number of Hydro AMR Subdomains" 1>> $datfile
	echo "#[4] Total number of points on the FD grid" 1>> $datfile
	echo "#[5] Number of points on the largest subdomains" 1>> $datfile

	segs="$(ls --ignore '*.*' | grep ${lev}_ | sort -n )"

	for seg in $segs ; do 
	        echo "#${seg}" 1>> $datfile

		cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
			| awk -F" " '{print $3}' \
			| sed -n -e '2{p;q}' )	

	        if [ -f "${run}/${seg}/Run/TStepperDiag.dat" ]
		then
			hdt=$(head -12 "${run}/${seg}/Run/TStepperDiag.dat" \
				| tail -1 \
				| awk -F"    " '{print $1}' \
				| awk -F"  " '{print $2}')
			tp=$(DomainInfo -d "${run}/${seg}/Run/GrDomain.input" \
				-UseLatestTime -Npoints \
				| tail -2)

			WorstSd=$(echo $tp | awk -F" " '{print $1}')
			Npoints=$(echo $tp | awk -F"N=" '{print $2}' \
				| awk -F"," '{print $1}')
			Nsubdomains=$(DomainInfo -d "${run}/${seg}/Run/GrDomain.input" \
				-Nsubdomains -IgnoreHist)

			echo $hdt $cores $Nsubdomains $Npoints $WorstSd 1>> $datfile
		fi
	done
done