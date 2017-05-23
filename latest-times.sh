#!/bin/bash

# usage:
# ./latest-times.sh

set -e
set -u
shopt -s nullglob

source ./paths.conf

echo -e "Simulation\tCores\tSubds\tLevels\tdT/dt\tTime\t\t\tSegment"

for run in $sdbase ; do 
	cd $run
	# set levs="0 1 2" e.g. in ./paths.conf
	for level in $levs; do

		seg="$(ls  --ignore "*.*" \
				| grep -E "Lev${level}_[A-Z]{2,3}" \
				| sort -n \
				| tail --lines 1)"

		# If user adds a file skip.txt to join directory, pass on
		# printing the digest for Lev${level}
		if [ -f "JoinedLev${level}/skip.txt" ] ; then
			continue
		fi

		# Check to make sure Run/ run has output TStepperDiag.dat. If
		# it hasn't, loop back over previous segments until it is
		# found, then use that segment for the "latest time"
		if [ -d "${seg}" ]
		then
			h=1
			while [ ! -f "${run}/${seg}/Run/TStepperDiag.dat" ] ;
			do
				h=$((h+1))
				lastseg="$(ls --ignore "*.*" \
						| grep -E "Lev${level}_[A-Z]{2,3}" \
						| sort -n \
						| tail --lines $h \
						| head --lines 1)"
				if [ "$lastseg" == "$seg" ] ; then
					break
				fi
				seg=$lastseg
			done
		else
			continue
		fi
		if [ ! -d "${seg}/Run" ] || [ ! -f "${seg}/Run/TStepperDiag.dat" ] ; then
			continue
		fi

		# Grab the information we want to display in the digest
		jobname=$(grep -i "Jobname" "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}')
		cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
					| awk -F" " '{print $3}' \
					| sed -n -e '2{p;q}' )
		latesttime=$(tail -n 1 "${run}/${seg}/Run/TStepperDiag.dat" \
					| awk -F" " '{print $1}')
		performance=$(tail -n 1 "${run}/${seg}/Run/TimeInfo.dat" \
					| awk -F" " '{print $6}')

		# Determine which HyDomain.input file to use
		if [ ! -f "${run}/${seg}/Run/NextHyDomain.{in,out}put" ]
		then
			isnext=''
		else
			isnext='Next'
		fi

		levels=$(cat "${run}/${seg}/Run/${isnext}HyDomain."*"put" \
				 | grep -E "BaseName = Interval.-Lev|BaseName = Interval-Lev" \
				 | wc -l )
		subdomains=$(DomainInfo -Nsubdomains \
								-d "${run}/${seg}/Run/${isnext}HyDomain."*"put" \
								-IgnoreHist)

		# Print the digest table to stdout
		echo -e $jobname"\t"$cores"\t"$subdomains"\t"$levels"\t"$performance"\t"$latesttime"\t"$seg

	done

done
