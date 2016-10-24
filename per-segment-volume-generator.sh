#!/bin/bash

# usage:
# ./per-segment-volume-generator.sh SFHo/M14_7-S9-SFHo/QE/Ev-eqsym/AMRLev1_Plunge/Lev1_SettleDisk/Lev1_AB

set -e
set -u
shopt -s nullglob

while [ $# -ge 1 ] ; do
        spath=$1
        basedir="/RQexec/brege/MicrophysicsSurvey/BHNS"
        sdbase="${basedir}/${spath}"
        shift

	echo `date`
	for run in $sdbase ; do
		cd $run
		echo "================================================================"
		echo "Descending into $run"

		vmdir="${run}/Run/VolumeMatterData"
		if [ -d $vmdir ]
		then

			echo "Candidate vmdir is: " $vmdir
			lastH5="$(ls ${vmdir} | grep -i "Vars_Interval" | tail --line 1)"
			echo $lastH5
			h=1
			while [ ! -f $vmdir/$lastH5 ] ;
			do
				echo "We didn't find any h5 files in" $vmdir
				echo "Try using a different segment..."
				continue
			done

			lasth5=$(ls -tr ${vmdir}/Vars_Interval*.h5 | tail --lines 1)
			echo "Latest written H5 file is: " $lasth5
			h5time=$(/RQusagers/brege/SpEC/Support/bin/TimesInH5File ${lasth5} | awk -F" " '{print $4}'  | tail --lines 1) 
#			echo "The latest time is: " $h5time
			hytimes=$(ls ${run}/Run/HyDomainAtTime*.txt | awk -F"    " '{print $2}' | awk -F".txt" '{print $1}')
#			echo "The domain times are: " $hytimes

			echo $h5time 1> "${basedir}/tmp/h5time.txt"
			echo $hytimes 1> "${basedir}/tmp/hytimes.txt"

			hytime=$(python $basedir/scripts/"match-domain-time-to-pv-file.py")
			echo "h5time is: " $h5time
			echo "hytime is: " $hytime

			OLDIFS=$IFS
			IFS=$'\n'
			hydomain="${run}/Run/HyDomainAtTime-    ${hytime}.txt"
			echo "hydomain is: " $hydomain 
			echo " "  

			jobname=$(grep -i "Jobname" "${run}/Run/MakeSubmit.input" | awk -F" " '{print $3}')
                        seg=$(basename $run)
			echo $seg
			vizdir="${basedir}/viz/${jobname}/${seg}"
			if [ ! -d "${vizdir}" ]
			then
				mkdir -p "${vizdir}"
				echo "created viz directory: " $vizdir
			        ApplyObservers \
			        -h5prefix Vars \
			        -UseTimes $h5time \
			        -NoDomainHistory \
			        -domaindir "${run}/Run" \
			        -domaininput "HyDomainAtTime-    ${hytime}.txt" \
			        -outputdir "${basedir}/viz/${jobname}/${seg}" \
			        -c "Subdomain(Items=ReadTensorFromDisk(Input=Rho0Phys;Time=${h5time};DeltaT=0.1;Dim=3;Dir=${run}/Run/VolumeMatterData/;RankSymm=;Output=Rho0Phys;H5FilePrefix=Vars;),ReadTensorFromDisk(Input=Temp;Time=${h5time};DeltaT=0.1;Dim=3;Dir=${run}/Run/VolumeMatterData/;RankSymm=;Output=Temp;H5FilePrefix=Vars;),)" \
			        -o "ConvertToVtk(Input=Rho0Phys,Temp; Basename=${h5time}_paraviewdata)"
				echo "new paraview data extracted in ${basedir}/viz/${jobname}/${seg}/${h5time}_paraviewdata"
			else
			        echo "Viz directory already exists!: " $vizdir
			fi

			IFS=$OLDIFS

                        rm "${basedir}/tmp/h5time.txt"
                        rm "${basedir}/tmp/hytimes.txt"

		fi
	done

done
