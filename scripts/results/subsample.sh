#!/bin/bash

source vars.sh

EXP_NAME="subsample"
TMP_DIR=$EXP_DIR/tmp_dir/$EXP_NAME
LOG_DIR=$EXP_DIR/logs/$EXP_NAME
USG_DIR=$EXP_DIR/usage/$EXP_NAME
MTC_DIR=$EXP_DIR/metrics/$EXP_NAME


#Make sure directory exists
mkdir -p $TMP_DIR #Temporary
mkdir -p $LOG_DIR #Logs
mkdir -p $USG_DIR #Usage
mkdir -p $MTC_DIR #Metrics

#rm -rf "${TMP_DIR}/*"

date
echo ":: Starting"
#Indexes
for index in ECOLI SENTERICA HUMANGUT; do
	RUN_DIR="${index}_RUNDIR"
	RUN_DIR="${!RUN_DIR}"
	echo "Run dir: ${RUN_DIR}"

	echo "Ref matrix: $RUN_DIR/matrices/$REF_MATRIX"

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo "Samples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo "Config: ${CONFIG}"

	echo -e "{\n" > $MTC_DIR/${index}_size.txt
	#Test subsampling sizes
	for s in 100 1000 10000 20000 50000 100000; do
		compressed_size=0

		ORDER=$TMP_DIR/order_${index}_${s}.bin
		TOOL=$KMCOMP_DIR/KMCOMP_v0.2/build/kmcomp
		INPUT=$RUN_DIR/matrices/original/$REF_MATRIX
		OUTPUT=$TMP_DIR/block_${index}_${s}
		echo "Subsample size: $s"
		echo "Computing path TSP (x5) ..."

		#Repeat computation of pi for clearer computation estimation
		for i in {0..4}; do
			export MEASURED_LOGFILE="$LOG_DIR/${index}_${s}_ref_${i}.txt"
		        export MEASURED_USAGEFILE="$USG_DIR/${index}_${s}_ref_${i}.txt"
			drop_caches
			monitor_cmd $TOOL -i $INPUT -s $s -b 65536 -c $SAMPLES --header 49 -t $ORDER -j "$MTC_DIR/metrics_${index}_${s}_ref_${i}.json" -z $OUTPUT --config-path $CONFIG
			rm $OUTPUT $OUTPUT.ef
		done
		echo "Path TSP computed"


		echo "Compressing matrices (x16) ..."
		#Compress 16 matrices using permutation
		for i in {0..15}; do
			INPUT=$RUN_DIR/matrices/original/matrix_${i}.cmbf
			OUTPUT=$TMP_DIR/block_${index}_${s}
			export MEASURED_LOGFILE="$LOG_DIR/${index}_${s}_${i}.txt"
			export MEASURED_USAGEFILE="$USG_DIR/${index}_${s}_${i}.txt"
			drop_caches
			monitor_cmd $TOOL -i $INPUT -c $SAMPLES --header 49 -b 65536 -f $ORDER -j "$MTC_DIR/metrics_${index}_${s}_${i}.json" -z $OUTPUT --config-path $CONFIG
			compressed_size=$(($compressed_size + $(stat -c "%s" $OUTPUT) + $(stat -c "%s" $OUTPUT.ef)))
			rm $OUTPUT $OUTPUT.ef
		done
		echo "Matrices compressed"

		#Estimate from 1/16 size
		compressed_size=$((16 * $compressed_size))

		if [ $s -eq 100000 ]; then
			echo -e "\t\"$s\": $compressed_size" >> $MTC_DIR/${index}_size.txt
		else
			echo -e "\t\"$s\": $compressed_size," >> $MTC_DIR/${index}_size.txt
		fi
	done
	echo -e "}" >> $MTC_DIR/${index}_size.txt

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
