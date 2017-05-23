#!/bin/bash

# usage:
# ./rejoin-segments.sh

set -e
set -u
shopt -s nullglob
source ./paths.conf

echo `date`

for run in $sdbase ; do 
	cd $run
	echo "Descending into " $run
	for level in $levs; do
		lastseg="$(ls --ignore '*.*' \
					| grep -E "Lev${level}_[A-Z]{2,3}" \
					| sort -n \
					| tail --lines 1)"

		# If user adds a file skip.txt to join directory, do not join		
		if [ -f "JoinedLev${level}/skip.txt" ]
		then
			echo "File skip.txt exists. Skipping Lev${level} joining.."
			continue
		fi

		if [ ! -d "${lastseg}" ] ;
		then
			echo "No available Lev${level} directory here, skipping.."
			continue
		else
			echo "Joining Lev${level} directories.."
		fi

		# Make sure to remove (failed) partial tmp dirs just in case
		if [ -d "JoinedLev${level}-tmp" ] ;
		then
			echo "Removing old temporary directory"
			rm -r "./JoinedLev${level}-tmp/"
		fi
	
		if [ -d "JoinedLev${level}" ] ;
		then 
			echo "Overwriting old joined data since the directory already exists.."
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
	done
done
