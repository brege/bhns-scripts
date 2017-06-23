#!/bin/bash

# usage:
# ./latest-times.sh

set -e
set -u
shopt -s nullglob

source ./paths.conf

RUNS=($sdbase)
SEGS=(Lev1_AH Lev1_AH Lev1_AH Lev1_AI Lev1_AE Lev1_BB Lev1_AF Lev1_BT) 
TIMES=(3.800 4.880 3.760 4.860 3.820 4.820 3.800 4.640)

j=0
while [ $j -lt 7 ]; do 
	jobname=$(grep -i "Jobname" "${RUNS[$j]}/${SEGS[$j]}/Run/MakeSubmit.input" \
				| awk -F" " '{print $3}')
	center=$(grep "Center=" "${RUNS[$j]}/${SEGS[$j]}/GrStateChangers.input" \
				| awk -F"Center=" '{print $2}' )
	size=$(grep "Width = " "${RUNS[$j]}/${SEGS[$j]}/GrDomain.input"  \
				| awk -F"Width = " '{print $2}' \
				| awk -F"*10" '{print $1}')
	density=$(grep "${TIMES[$j]}0" "${RUNS[$j]}/${SEGS[$j]}/Run/MatterObservers/DensestPoint.dat" \
				| awk -F"  " '{print $6}' \
				| awk -F"  " '{print $1}' )
    echo -e $jobname"\t"$center"\t"$size $density
    j=$((j+1))
done
