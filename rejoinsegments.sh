#!/bin/bash

# usage:
# ./rejoinsegments.sh

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
	lastseg="$(ls --ignore '*.*' | grep ${lev}_ | sort -n | tail --lines 1)"
	if [ -d "${run}/${lastseg}/Run" ] ;
	then
		# Make sure to remove (failed) partial tmp dirs just in case
		if [ -d JoinedLev1-tmp ] ;
		then
			echo "Removing old temporary directory"
			rm -r ./JoinedLev1-tmp/
		fi

		if [ -d JoinedLev1 ] ;
		then 
			echo "Overwriting old joined data since the directory already exists.."
		#	rm -r ./JoinedLev1/
			/RQusagers/brege/SpEC/Support/bin/CombineSegments.py -e dat -L 1 -o JoinedLev1-tmp -f Constraints MatterObservers ApparentHorizon TStepperDiag.dat TimeInfo.dat
			cp -r JoinedLev1-tmp/* JoinedLev1/
			rm -r ./JoinedLev1-tmp/
		else
			echo "No joined data here.  Proceeding without overwriting anything.."
			/RQusagers/brege/SpEC/Support/bin/CombineSegments.py -e dat -L 1 -o JoinedLev1 -f Constraints MatterObservers ApparentHorizon TStepperDiag.dat TimeInfo.dat 
		fi
		echo "Data successfully joined!"
	else 
		echo "Hmm," $run/$lastseg "hasn't run anything yet.  Skipping this for now.."
	fi
done
