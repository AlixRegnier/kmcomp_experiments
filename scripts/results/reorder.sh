#!/bin/bash

source vars.sh

EXP_NAME="reorder"
TMP_DIR=$EXP_DIR/tmp_dir/$EXP_NAME
LOG_DIR=$EXP_DIR/logs/$EXP_NAME
USG_DIR=$EXP_DIR/usage/$EXP_NAME
MTC_DIR=$EXP_DIR/metrics/$EXP_NAME


#Make sure directory exists
mkdir -p $TMP_DIR #Temporary
mkdir -p $LOG_DIR #Logs
mkdir -p $USG_DIR #Usage
mkdir -p $MTC_DIR #Metrics

rm -rf "${TMP_DIR}/*"

date
echo ":: Starting"
#Indexes
for index in ECOLI SENTERICA HUMANGUT; do
	RUN_DIR="${index}_RUNDIR"
	RUN_DIR="${!RUN_DIR}"
	echo "Run dir: ${RUN_DIR}"

	echo "Ref matrix: $RUN_DIR/matrices/${index}_ref.cmbf"
	cp $RUN_DIR/matrices/$REF_MATRIX $TMP_DIR/${index}_ref.cmbf

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo "Samples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo "Config: ${CONFIG}"

	ORDER=$TMP_DIR/order_${index}.bin
	echo "Computing path TSP"
	$KMCOMP_DIR/KMCOMP_v0.2/build/kmcomp -i $TMP_DIR/${index}_ref.cmbf -c $SAMPLES --header 49 -z $TMP_DIR/block_${index}_ref -t $ORDER -e 10.0 --config-path $CONFIG
	echo "Computed order to: $ORDER"
	echo "Reordering reference matrix"

	#Reorder each matrices (repeated x10)
	for kmcomp in exp_bitpacking v0.2; do
		TOOL=$KMCOMP_DIR/KMCOMP_${kmcomp}/build/kmcomp
		echo -e "$kmcomp"

		for i in {0..9}; do
			echo "$i"
			rm $CONFIG
			cp $RUN_DIR/matrices/matrix_${i}.cmbf $TMP_DIR/matrix_${i}.cmbf
			export MEASURED_LOGFILE="$LOG_DIR/${index}_${kmcomp}_${i}.txt"
	                export MEASURED_USAGEFILE="$USG_DIR/${index}_${kmcomp}_${i}.txt"
			drop_caches
			monitor_cmd $TOOL -i $TMP_DIR/matrix_${i}.cmbf -z $TMP_DIR/xxx -c $SAMPLES --header 49 -f $ORDER -j "$MTC_DIR/metrics_${index}_${kmcomp}_${i}.json" --config-path $CONFIG
		done
	done

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
