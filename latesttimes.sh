#!/bin/bash

# usage:
# ./latesttimes.sh Lev0 Lev1 Lev2

set -e
set -u
shopt -s nullglob

while [ $# -ge 1 ] ; do
        lev=$1
        basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
        sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_SettleDisk"
#	sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/"
        shift

	echo `date`
	echo -e "Simulation\tCores\tSubds\tLevels\tSegment\tTime"

	for run in $sdbase ; do 
		cd $run
                seg="$(ls --ignore '*.*' | grep ${lev}_ | sort -n | tail --lines 1)"
		if [ ! -f "${run}/${seg}/Run/TStepperDiag.dat" ] ;
		then
			seg="$(ls --ignore '*.*' | grep ${lev}_ | sort -n | tail --lines 2 | head --lines 1)"
		fi
		jobname=$(grep -i "Jobname" "${run}/${seg}/Run/MakeSubmit.input" | awk -F" " '{print $3}')
		cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" | awk -F" " '{print $3}' | sed -n -e '2{p;q}' )
		latesttime=$(tail -n 1 "${run}/${seg}/Run/TStepperDiag.dat" | awk -F" " '{print $1}')
		if [ ! -f "${run}/${seg}/Run/NextHyDomain.input" ]
		then
	                levels=$(cat "${run}/${seg}/Run/HyDomain.input" | grep "BaseName = IntervalB-Lev" | wc -l )
			subdomains=$(/RQusagers/brege/SpEC/Support/bin/DomainInfo -Nsubdomains -d "${run}/${seg}/Run/HyDomain.input" -IgnoreHist)
		else
			levels=$(cat "${run}/${seg}/Run/NextHyDomain.input" | grep "BaseName = IntervalB-Lev" | wc -l )
	#		levels=$(cat "${run}/${seg}/Run/NextHyDomain.input" | grep "BaseName = Interval-Lev" | wc -l )
			subdomains=$(/RQusagers/brege/SpEC/Support/bin/DomainInfo -Nsubdomains -d "${run}/${seg}/Run/NextHyDomain.input" -IgnoreHist)
		fi
		echo -e $jobname"\t"$cores"\t"$subdomains"\t"$levels"\t"$seg"\t"$latesttime


	done

done
