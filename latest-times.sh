#!/bin/bash

# usage:
# ./latest-times.sh

set -e
set -u
shopt -s nullglob

source ./paths.conf

echo `date`
echo -e "Simulation\tCores\tSubds\tLevels\tSegment\tTime"

for run in $sdbase ; do 
	cd $run
	# set levs="0 1 2" e.g. in ./paths.conf
	for level in $levs; do

		seg="$(ls  --ignore "*.*" \
				| grep -E "Lev${level}_[A-Z]{2,3}" \
				| sort -n \
				| tail --lines 1)"

		if [ -d "${seg}" ]
		then
			h=1
			while [ ! -f "${run}/${seg}/Run/TStepperDiag.dat" ] ;
			do
				h=$((h+1))
				seg="$(ls --ignore "*.*" \
						| grep -E "Lev${level}_[A-Z]{2,3}" \
						| sort -n \
						| tail --lines $h \
						| head --lines 1)"
			done
		else
			continue
		fi

		jobname=$(grep -i "Jobname" "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}')
		cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}' \
					| sed -n -e '2{p;q}' )
		latesttime=$(tail -n 1 "${run}/${seg}/Run/TStepperDiag.dat" \
					| awk -F" " '{print $1}')

		if [ ! -f "${run}/${seg}/Run/NextHyDomain.{in,out}put" ]
		then
			levels=$(cat "${run}/${seg}/Run/HyDomain.input" \
					 | grep -E "BaseName = Interval.-Lev|BaseName = Interval-Lev" \
					 | wc -l )
			subdomains=$(DomainInfo -Nsubdomains \
									-d "${run}/${seg}/Run/HyDomain.input" \
									-IgnoreHist)
		else
			levels=$(cat "${run}/${seg}/Run/NextHyDomain.{in,out}put" \
					 | grep -E "BaseName = Interval.-Lev|BaseName = Interval-Lev" \
					 | wc -l )
			subdomains=$(DomainInfo -Nsubdomains \
									 -d "${run}/${seg}/Run/NextHyDomain.{in,out}put" \
									 -IgnoreHist)
		fi

		echo -e $jobname"\t"$cores"\t"$subdomains"\t"$levels"\t"$seg"\t"$latesttime

	done

done
