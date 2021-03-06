#!/bin/bash

# usage:
# ./gr-domain-info.sh

set -e
set -u
shopt -s nullglob

source ./paths.conf

for run in $sdbase ; do
	cd $run
	#levs="0 1 5"

	for levels in $levs ; do

		datfile="${run}/JoinedLev${levels}/GrDomainInfo.dat"

		if [ ! -d "${run}/JoinedLev${levels}/" ] ; 
		then
			echo "no JoinedLev${levels} directory here, skipping.."
			continue
		fi

		#echo `date`
		echo "Descending into " $run
		echo "#[1] Time" 1> $datfile # overwrites an existing file with this one line
		echo "#[2] Number of Cores" 1>> $datfile # appends to it hereafter
		echo "#[3] Number of Spectral Subdomains" 1>> $datfile
		echo "#[4] Total number of points on the GR grid" 1>> $datfile
		echo "#[5] Number of points on the largest subdomain" 1>> $datfile
		echo "#[6] Grid spacing of finest grid" 1>> $datfile

		segs="$(ls --ignore '*.*' | grep -E "Lev${levels}_[A-Z]{2,3}" | sort -n )"

		for seg in $segs ; do 
			echo "#${seg}" 1>> $datfile
	
			cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}' \
					| sed -n -e '2{p;q}' )	
	
			if [ -f "${run}/${seg}/Run/TStepperDiag.dat" ]
			then
				hdt=$(tail -1 "${run}/${seg}/Run/TStepperDiag.dat" \
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
				dx=$(DomainInfo -d "${run}/${seg}/Run/GrDomain.input" \
					--dxmin \
					--UseLatestTime \
					| head -6 \
					| tail -1 )
				dxmin=$(echo $dx \
					| awk -F" " '{print $1}' \
					| awk -F"=" '{print $2}')
				
				echo $hdt $cores $Nsubdomains $Npoints $WorstSd $dxmin>> $datfile
			fi
		done
	done
done
