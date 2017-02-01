#!/bin/bash

# usage:
# ./latest-times.sh Lev0 Lev1 Lev2

set -e
set -u
shopt -s nullglob

#basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
#sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMRLev1_Plunge/Lev?_SettleDisk"
#sdbase="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/"
source ./paths.conf

echo `date`
echo -e "Simulation\tCores\tSubds\tLevels\tSegment\tTime"

for run in $sdbase ; do 
	cd $run
	levs="0 1 5"
	for level in $levs; do

                lastseg="$(ls --ignore '*.*' | grep "Lev${level}_" | sort -n | tail --lines 1)"
                if [ ! -d "${lastseg}" ] ;
                then
#                        echo "no available Lev${level} directory here, skipping.."
                        continue
                fi


                seg="$(ls --ignore '*.*' \
                       | grep "Lev${level}_" \
                       | sort -n \
                       | tail --lines 1)"
		if [ ! -f "${run}/${seg}/Run/TStepperDiag.dat" ] ;
		then
			seg="$(ls --ignore '*.*' \
                               | grep "Lev${level}_" \
                               | sort -n \
                               | tail --lines 2 \
                               | head --lines 1)"
		fi

		jobname=$(grep -i "Jobname" "${run}/${seg}/Run/MakeSubmit.input" \
                        | awk -F" " '{print $3}')
                cores=$(grep -i 'Cores\ =\ ' "${run}/${seg}/Run/MakeSubmit.input" \
                        | awk -F" " '{print $3}' \
                        | sed -n -e '2{p;q}' )
		latesttime=$(tail -n 1 "${run}/${seg}/Run/TStepperDiag.dat" \
                             | awk -F" " '{print $1}')

		if [ ! -f "${run}/${seg}/Run/NextHyDomain.input" ]
		then
	                levels=$(cat "${run}/${seg}/Run/HyDomain.input" \
                                 | grep "BaseName = IntervalB-Lev" \
                                 | wc -l )
			subdomains=$(DomainInfo -Nsubdomains \
                                                -d "${run}/${seg}/Run/HyDomain.input" \
                                                -IgnoreHist)
		else
			levels=$(cat "${run}/${seg}/Run/NextHyDomain.input" \
                                 | grep "BaseName = IntervalB-Lev" \
                                 | wc -l )
#i			levels=$(cat "${run}/${seg}/Run/NextHyDomain.input" \
#                                | grep "BaseName = Interval-Lev" \
#                                | wc -l )
			subdomains=$(DomainInfo -Nsubdomains \
                                     -d "${run}/${seg}/Run/NextHyDomain.input" \
                                     -IgnoreHist)
		fi

		echo -e $jobname"\t"$cores"\t"$subdomains"\t"$levels"\t"$seg"\t"$latesttime


	done

done
