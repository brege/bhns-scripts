#!/bin/bash

# usage:
# ./domain-info.sh

set -e
set -u
shopt -s nullglob

lev="Lev1"
basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_SettleDisk"
#sdbase=$PWD

for run in $sdbase ; do
	cd $run

	datfile="${run}/JoinedLev1/DomainInfo.dat"
	
	#echo `date`
	echo "Descending into " $run
	echo "#[1] Time" 1>> $datfile
	echo "#[2] Number of Cores" 1>> $datfile
	echo "#[3] Number of Hydro AMR Subdomains" 1>> $datfile
	echo "#[4] Total number of points on the FD grid" 1>> $datfile

	segs="$(ls --ignore '*.*' | grep ${lev}_ | sort -n )"

	for seg in $segs ; do 
	        echo "#${seg}" 1>> $datfile
		cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" | awk -F" " '{print $3}' | sed -n -e '2{p;q}' )	
	        if [ -f "${run}/${seg}/Run/TStepperDiag.dat" ]
		then
			hdtimes=$(ls ${run}/${seg}/Run/HyDomainAtTime*.txt | awk -F"    " '{print $2}' | awk -F".txt" '{print $1}')
			for hdt in $hdtimes ; do
				di=$(DomainInfo -d="${run}/${seg}/Run/HyDomainAtTime-    ${hdt}.txt" -IgnoreHist -Npoints | tail -1)
				Npoints=$(echo $di | awk -F"N=" '{print $2}' | awk -F"," '{print $1}')
				Nsubdomains=$(DomainInfo -Nsubdomains -d "${run}/${seg}/Run/HyDomainAtTime-    ${hdt}.txt" -IgnoreHist)
				echo $hdt $cores $Nsubdomains $Npoints 1>> $datfile
			
			done
		fi
	done
done
