#!/bin/bash

# usage:
# ./domain-info.sh

set -e
set -u
shopt -s nullglob

source ./paths.conf


for run in $sdbase ; do
	cd $run

	for levels in $levs ; do
		datfile="${run}/JoinedLev${levels}/DomainInfo.dat"

		if [ ! -d "${run}/JoinedLev${levels}/" ] ;
		then
			echo "no JoinedLev${levels} directory here, skipping.."
			continue
		fi	
		#echo `date`
		echo "Descending into " $run
		echo "#[1] Time" 1> $datfile # overwrites an existing file with this one line
		echo "#[2] Number of Cores" 1>> $datfile # appends to it hereafter
		echo "#[3] Number of Hydro AMR Subdomains" 1>> $datfile
		echo "#[4] Total number of points on the FD grid" 1>> $datfile

		segs="$(ls --ignore '*.*' | grep -E "Lev${levels}_[A-Z]{2,3}" | sort -n )"

		for seg in $segs ; do 
			echo "#${seg}" 1>> $datfile
			cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}' \
					| sed -n -e '2{p;q}' )

			if [ -f "${run}/${seg}/Run/TStepperDiag.dat" ]
			then
				hdtimes=$(ls "${run}/${seg}/Run/"HyDomainAtTime*.txt \
						| awk -F"    " '{print $2}' \
						| awk -F".txt" '{print $1}')
				for hdt in $hdtimes ; do
					di=$(DomainInfo -d="${run}/${seg}/Run/HyDomainAtTime-    ${hdt}.txt" \
						-IgnoreHist -Npoints | tail -1)
					Npoints=$(echo $di \
							| awk -F"N=" '{print $2}' \
							| awk -F"," '{print $1}')
					Nsubdomains=$(DomainInfo -d "${run}/${seg}/Run/HyDomainAtTime-    ${hdt}.txt" \
								-Nsubdomains -IgnoreHist)
					echo $hdt $cores $Nsubdomains $Npoints 1>> $datfile
				done
			fi
		done
	done
done
