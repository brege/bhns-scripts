#!/bin/bash

# usage:
# ./volume-generator.sh Lev1 Lev5

set -e
set -u
shopt -s nullglob
source ./paths.conf

while [ $# -ge 1 ] ; do
	lev=$1
	shift

	echo `date`
	for run in $sdbase ; do
		cd $run
		echo "================================================================"
		echo "Descending into $run"

		seg="$(ls  --ignore "*.*" \
				| grep -E "${lev}_[A-Z]{2,3}" \
				| sort -n \
				| tail --lines 1)"
		vmdir="${run}/${seg}/Run/VolumeMatterData"

		# Check to make sure there's h5 files in the vmdir. If there aren't
		# any, loop back over previous segments until one is found, then use
		# that segment.
		if [ -d "${seg}" ]
		then
			echo "Candidate vmdir is: " $vmdir
			lasth5=$(ls -tr "${vmdir}" | grep -i "Vars_Interval" | tail --lines 1)

			h=1
			while [ ! -f "${vmdir}/${lasth5}" ] ;
			do
				h=$((h+1))
				lastseg="$(ls --ignore "*.*" \
						| grep -E "${lev}_[A-Z]{2,3}" \
						| sort -n \
						| tail --lines $h \
						| head --lines 1)"
				if [ "$lastseg" == "$seg" ] ; then
					break
				fi
				seg=$lastseg
				vmdir="${run}/${seg}/Run/VolumeMatterData"
				lasth5=$(ls -tr "${vmdir}" | grep -i "Vars_Interval" | tail --lines 1)
			done
		else
			continue
		fi
		if [ ! -d "${vmdir}" ] ; then
			continue
		fi

		if [ -f "${vmdir}/${lasth5}" ] 
		then
			
			echo "Latest written H5 file is: " $lasth5
			h5time=$(TimesInH5File "${vmdir}/${lasth5}" \
					 | awk -F" " '{print $4}'  \
					 | tail --lines 1) 
#			echo "The latest time is: " $h5time
			hytimes=$(ls ${run}/${seg}/Run/HyDomainAtTime*.txt \
					  | awk -F"    " '{print $2}' \
					  | awk -F".txt" '{print $1}')
#			echo "The domain times are: " $hytimes

			echo $h5time 1> "${basedir}/tmp/h5time.txt"
			echo $hytimes 1> "${basedir}/tmp/hytimes.txt"

			export basedir
			hytime=$(python "${basedir}/scripts/match-domain-time-to-pv-file.py")
			echo "h5time is: " $h5time
			echo "hytime is: " $hytime

			OLDIFS=$IFS
			IFS=$'\n'
			hydomain="${run}/${seg}/Run/HyDomainAtTime-    ${hytime}.txt"
			echo "hydomain is: " $hydomain 
			echo " "  

			jobname=$(grep -i "Jobname" "${run}/${seg}/Run/MakeSubmit.input" \
					  | awk -F" " '{print $3}')
			vizdir="${basedir}/viz/${jobname}/${seg}"
			if [ ! -d "${vizdir}" ]
			then
				mkdir -p "${vizdir}"
				echo "created viz directory: " $vizdir
				ApplyObservers \
					-h5prefix Vars \
					-UseTimes $h5time \
					-NoDomainHistory \
					-domaindir "${run}/${seg}/Run" \
					-domaininput "HyDomainAtTime-    ${hytime}.txt" \
					-outputdir "${basedir}/viz/${jobname}/${seg}" \
					-c "Subdomain(Items=ReadTensorFromDisk(Input=Rho0Phys;Time=${h5time};DeltaT=0.1;Dim=3;Dir=${run}/${seg}/Run/VolumeMatterData/;RankSymm=;Output=Rho0Phys;H5FilePrefix=Vars;),ReadTensorFromDisk(Input=Temp;Time=${h5time};DeltaT=0.1;Dim=3;Dir=${run}/${seg}/Run/VolumeMatterData/;RankSymm=;Output=Temp;H5FilePrefix=Vars;),)" \
					-o "ConvertToVtk(Input=Rho0Phys,Temp; Basename=${h5time}_paraviewdata)"
				echo "new paraview data extracted in ${basedir}/viz/${jobname}/${seg}/${h5time}_paraviewdata"
			else
				echo "Viz directory already exists!: " $vizdir
			fi

			IFS=$OLDIFS

			rm "${basedir}/tmp/h5time.txt"
			rm "${basedir}/tmp/hytimes.txt"

		else
			echo "No H5 files found, continuing to next system.."
			continue
		fi
	done

done
