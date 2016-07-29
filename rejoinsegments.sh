#!/bin/bash

# usage:
# ./rejoinsegments.sh

set -e
set -u
shopt -s nullglob

lev="Lev1"
basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_SettleDisk"

echo `date`

for run in $sdbase ; do 
	cd $run
	lastseg="$(ls --ignore '*.*' | grep ${lev}_ | sort -n | tail --lines 1)"
	echo "Descending into " $run
	if [ -d $run/$lastseg/Run ] ;
	then
		if [ -d JoinedLev1 ] ;
		then 
			echo "Removingi old joined data since the directory already exists.."
			rm -r ./JoinedLev1
		else
			echo "No joined data here.  Proceeding without deleting anything.."
		fi
		/home/brege/SpEC/Support/bin/CombineSegments.py -L 1 -o JoinedLev1 -f Constraints MatterObservers TStepperDiag.dat TimeInfo.dat
		echo "Data successfully joined!"
	else 
		echo "Hmm," $run/$lastseg "hasn't run anything yet.  Skipping this for now.."
	fi
done
