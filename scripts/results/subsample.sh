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

	echo -e "\tRef matrix: $RUN_DIR/matrices/$REF_MATRIX"

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo -e "\tSamples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo -e "\tConfig: ${CONFIG}"

	#Test subsampling sizes
	for s in 100 200 500 1000 10000 20000 50000 100000; do
		compressed_size=0

		ORDER=$TMP_DIR/order_${index}_${s}.bin
		TOOL=$BMS/BMS_no_dm_vptree_zstd_wlog/build/main_bitmatrixshuffle
		INPUT=$RUN_DIR/matrices/original/$REF_MATRIX
		OUTPUT=$TMP_DIR/block_${index}_${s}
		echo -e "\tSubsample size: $s"
		echo -e "\t\t:: Computing path TSP"
		echo -e "\t\tComputed order to: $ORDER"

		export MEASURED_LOGFILE="$LOG_DIR/${index}_${s}_ref.txt"
                export MEASURED_USAGEFILE="$USG_DIR/${index}_${s}_ref.txt"

		monitor_cmd $TOOL -i $INPUT -s $s --wlog 16 -b 65536 -c $SAMPLES --header 49 -t $ORDER -j "$MTC_DIR/metrics_${index}_${s}_ref.json" -z $OUTPUT --config-path $CONFIG
		compressed_size=$(($compressed_size + $(stat -c "%s" $OUTPUT) + $(stat -c "%s" $OUTPUT.ef)))
		rm $OUTPUT $OUTPUT.ef
		for i in {0..6}; do
			INPUT=$RUN_DIR/matrices/original/matrix_${i}.cmbf
			OUTPUT=$TMP_DIR/block_${index}_${s}
			export MEASURED_LOGFILE="$LOG_DIR/${index}_${s}_${i}.txt"
			export MEASURED_USAGEFILE="$USG_DIR/${index}_${s}_${i}.txt"
			monitor_cmd $TOOL -i $INPUT -c $SAMPLES --header 49 --wlog 16 -b 65536 -f $ORDER -j /dev/null -z $OUTPUT --config-path $CONFIG "$MTC_DIR/metrics_${index}_${s}_${i}.json" -z $OUTPUT --config-path $CONFIG
			compressed_size=$(($compressed_size + $(stat -c "%s" $OUTPUT) + $(stat -c "%s" $OUTPUT.ef)))
			rm $OUTPUT $OUTPUT.ef
		done

		#Estimate from 1/32 size
		compressed_size=$((32 * $compressed_size))
		echo -e "$s\t$compressed_size" >> $MTC_DIR/${index}_size.txt
	done

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
