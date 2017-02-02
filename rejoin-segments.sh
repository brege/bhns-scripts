#!/bin/bash

# usage:
# ./rejoin-segments.sh

set -e
set -u
shopt -s nullglob

lev="Lev1"
basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
#plbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge"
sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_SettleDisk"
echo `date`

#for run in $plbase ; do 
for run in $sdbase ; do 
	cd $run
	echo "Descending into " $run
#	lastseg="$(ls --ignore '*.*' --ignore '*SettleDisk' | grep ${lev}_ | sort -n | tail --lines 1)"
	levs="0 1 5"
	for level in $levs; do
		lastseg="$(ls --ignore '*.*' | grep "Lev${level}_" | sort -n | tail --lines 1)"

		if [ ! -d "${lastseg}" ] ;
		then
			echo "no available Lev${level} directory here, skipping.."
			continue
		fi

		if [ -d "${run}/${lastseg}/Run" ] ;
		then
			# Make sure to remove (failed) partial tmp dirs just in case
			if [ -d "JoinedLev${level}-tmp" ] ;
			then
				echo "Removing old temporary directory"
				rm -r "./JoinedLev${level}-tmp/"
			fi
	
			if [ -d "JoinedLev${level}" ] ;
			then 
				echo "Overwriting old joined data since the directory already exists.."
			#	rm -r ./JoinedLev1/
				CombineSegments.py -e dat \
								   -L $level \
								   -o "JoinedLev${level}-tmp" \
								   -f Constraints MatterObservers \
									  ApparentHorizon TStepperDiag.dat \
									  TimeInfo.dat MemoryInfo.dat
				cp -r "JoinedLev${level}-tmp/"* "JoinedLev${level}/"
				rm -r "./JoinedLev${level}-tmp/"
			else
				echo "No joined data here.	Proceeding without overwriting anything.."
				CombineSegments.py -e dat \
								   -L $level \
								   -o "JoinedLev${level}" \
								   -f Constraints MatterObservers \
									  ApparentHorizon TStepperDiag.dat \
									  TimeInfo.dat MemoryInfo.dat 
			fi
			echo "Data successfully joined!"
		else 
			echo "Hmm," $run/$lastseg "hasn't run anything yet.  Skipping this for now.."
		fi
	done
done
