#!/bin/bash

# usage:
# ./keeplastcheckpoint.sh Lev0 Lev1 Lev2

set -e
set -u
shopt -s nullglob

while [ $# -ge 1 ] ; do
        lev=$1
        basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
        logfile_chaining="${basedir}/log/checkpoint-cleaner-chaining.log"
        logfile_saved="${basedir}/log/checkpoint-cleaner-saved.log"
        sdchains="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/*${lev}_SettleDisk/${lev}_??/Run/ChainingCheckpoints"
        plchains="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_??/Run/ChainingCheckpoints"
        sdsaved="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/*${lev}_SettleDisk/${lev}_??/Run/SavedCheckpoints"
        plsaved="${basedir}/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/${lev}_??/Run/SavedCheckpoints"
        shift

	echo `date` 1>> $logfile_chaining
        
#	for cpdir in /RQexec/brege/MicrophysicsSurvey/BHNS/*/M1?_7-S9-*/QE/Ev-eqsym/*AMR${lev}_Plunge/*${lev}_SettleDisk/${lev}_??/Run/ChainingCheckpoints ; do
	for cpdir in $sdchains $plchains ; do
                cps="$(cd $cpdir ; ls | sort -n | head --lines -1)"
                for cp in $cps ; do
                        echo "removing incremental checkpoint:  " $cpdir/$cp 1>> $logfile_chaining
              		rm -r  $cpdir/$cp
                done
        done

	echo "========================================================================" 1>> $logfile_chaining
	echo `date` 1>> $logfile_saved

	for cpdir in $sdsaved $plsaved; do
		cps="$(cd $cpdir ; ls | sort -n )"
		for cp in $cps ; do
 			sourcefile=$cpdir/$cp/Source-Vars_*.h5
			for sf in $sourcefile ; do
	                        if [ -n $sf ] 
				then
					echo "removing source file: " $sf 1>> $logfile_saved
					rm $sf 
				fi
			done 
		done
        done
	echo "========================================================================" 1>> $logfile_saved

done
