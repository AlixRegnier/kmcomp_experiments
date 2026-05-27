#!/bin/bash

export MEASURED_LOGFILE="logs.txt"
export MEASURED_USAGEFILE="usage.txt"

monitor_cmd() {
    local time_output

    # Run the command with /usr/bin/time and capture its output
    echo "Timed command: $@" > "$MEASURED_LOGFILE"
    time_output=$(/usr/bin/time -f "%e %M" "$@" 2>&1 >> "$MEASURED_LOGFILE" | tail -n 1 | sed 's/.*\r//')

    # Extract wall time and RSS memory from the output
    export MEASURED_WALL_TIME=$(echo "$time_output" | cut -f1 -d' ')
    export MEASURED_RSS_MEMORY=$(echo "$time_output" | cut -f2 -d' ')
    export MEASURED_COMMAND="$@"

    # Write out usage values
    echo -e "{\n\t\"command\": \"$MEASURED_COMMAND\"\n\t\"time(s)\": $MEASURED_WALL_TIME\n\t\"memory(KB)\": $MEASURED_RSS_MEMORY\n}" > "$MEASURED_USAGEFILE"
    export MEASURED_WALL_TIME="NaN"
    export MEASURED_RSS_MEMORY="NaN"
    export MEASURED_COMMAND="NaN"

    echo "\$\$\$ $@"
}

source vars.sh

EXP_NAME="compression"
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

	echo -e "\tRef matrix: $RUN_DIR/matrices/${index}_ref.cmbf"
	cp $RUN_DIR/matrices/original/$REF_MATRIX $TMP_DIR/${index}_ref.cmbf

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo -e "\tSamples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo -e "\tConfig: ${CONFIG}"

	ORDER=$TMP_DIR/order_${index}.bin
	echo -e "\t:: Computing path TSP"
	$BMS_DIR/BMS_no_dm_vptree/build/main_bitmatrixshuffle -i $TMP_DIR/${index}_ref.cmbf -c $SAMPLES -b 65536 --header 49 -z $TMP_DIR/temp -t $ORDER --config-path $CONFIG >/dev/null
	echo "\$\$\$ $BMS_DIR/BMS_no_dm_vptree/build/main_bitmatrixshuffle -i $TMP_DIR/${index}_ref.cmbf -c $SAMPLES -b 65536 --header 49 -z $TMP_DIR/temp -t $ORDER --config-path $CONFIG >/dev/null"
	echo -e "\t\tComputed order to: $ORDER"
	echo -e "\t:: Reordering reference matrix"

	#Test block sizes (dictsize = blocksize)
	compressed_size=0
	compressed_no_reorder_size=0
	CONFIG=$TMP_DIR/config_${index}.cfg

	TOOL=$BMS/BMS_no_dm_vptree_zstd_wlog/build/main_bitmatrixshuffle
	INPUT_R=$RUN_DIR/matrices/$REF_MATRIX
	INPUT=$RUN_DIR/matrices/original/$REF_MATRIX
	OUTPUT=$TMP_DIR/block_${index}_ref
	OUTPUT_NO_REORDER=$TMP_DIR/block_${index}_no_reorder_ref

	echo -e "\t\tBlock size: 65536"

	export MEASURED_LOGFILE="$LOG_DIR/${index}_ref.txt"
    export MEASURED_USAGEFILE="$USG_DIR/${index}_ref.txt"
	$TOOL -i $INPUT_R -z $OUTPUT -c $SAMPLES --header 49 -b 65536 -s 10000 --wlog 16 -n -j "$MTC_DIR/metrics_${index}_ref.json" --config-path $CONFIG

	export MEASURED_LOGFILE="$LOG_DIR/${index}_no_reorder_ref.txt"
    export MEASURED_USAGEFILE="$USG_DIR/${index}_no_reorder_ref.txt"
	$TOOL -i $INPUT -z $OUTPUT_NO_REORDER -c $SAMPLES --header 49 -b 65536 -s 10000 --wlog 16 -n -j "$MTC_DIR/metrics_${index}_no_reorder_ref.json" --config-path $CONFIG

	compressed_size=$(($compressed_size + $(stat -c "%s" $OUTPUT) + $(stat -c "%s" $OUTPUT.ef)))
	rm $OUTPUT $OUTPUT.ef
	compressed_no_reorder_size=$(($compressed_no_reorder_size + $(stat -c "%s" $OUTPUT_NO_REORDER) + $(stat -c "%s" $OUTPUT_NO_REORDER.ef)))
	rm $OUTPUT_NO_REORDER $OUTPUT_NO_REORDER.ef

	for i in {0..6}; do
		echo -e "\t\tMatrix $i"
		INPUT_R=$RUN_DIR/matrices/matrix_${i}.cmbf
		INPUT=$RUN_DIR/matrices/original/matrix_${i}.cmbf
		OUTPUT=$TMP_DIR/block_${index}_${i}
		OUTPUT_NO_REORDER=$TMP_DIR/block_${index}_no_reorder_${i}

		export MEASURED_LOGFILE="$LOG_DIR/${index}_${i}.txt"
        export MEASURED_USAGEFILE="$USG_DIR/${index}_${i}.txt"
		monitor_cmd $TOOL -i $INPUT_R -z $OUTPUT -c $SAMPLES --header 49 -b 65536 -s 10000 --wlog 16 -n -j "$MTC_DIR/metrics_${index}_${i}.json" --config-path $CONFIG

		export MEASURED_LOGFILE="$LOG_DIR/${index}_no_reorder_${i}.txt"
        export MEASURED_USAGEFILE="$USG_DIR/${index}_no_reorder_${i}.txt"
		monitor_cmd $TOOL -i $INPUT -z $OUTPUT_NO_REORDER -c $SAMPLES --header 49 -b 65536 -s 10000 --wlog 16 -n -j "$MTC_DIR/metrics_${index}_no_reorder_${i}.json" --config-path $CONFIG

		compressed_size=$(($compressed_size + $(stat -c "%s" $OUTPUT) + $(stat -c "%s" $OUTPUT.ef)))
		rm $OUTPUT $OUTPUT.ef
		compressed_no_reorder_size=$(($compressed_no_reorder_size + $(stat -c "%s" $OUTPUT_NO_REORDER) + $(stat -c "%s" $OUTPUT_NO_REORDER.ef)))
		rm $OUTPUT_NO_REORDER $OUTPUT_NO_REORDER.ef
	done

	compressed_size=$((32 * $compressed_size))
	compressed_no_reorder_size=$((32 * $compressed_no_reorder_size))
	echo -e "$compressed_size" >> $MTC_DIR/${index}_size.txt
	echo -e "$compressed_no_reorder_size" >> $MTC_DIR/${index}_no_reorder_size.txt
done

#Clean temporary directory
#rm -rf "${TMP_DIR}/*"

echo "Done!"

date
