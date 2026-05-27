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

EXP_NAME="permutation"
TMP_DIR=$EXP_DIR/tmp_dir/$EXP_NAME
LOG_DIR=$EXP_DIR/logs/$EXP_NAME
USG_DIR=$EXP_DIR/usage/$EXP_NAME
MTC_DIR=$EXP_DIR/metrics/$EXP_NAME

#Make sure directory exists
mkdir -p $TMP_DIR #Temporary
mkdir -p $LOG_DIR #Logs
mkdir -p $USG_DIR #Usage
mkdir -p $MTC_DIR #Metrics

date
echo ":: Starting"
#Indexes
for index in ECOLI SENTERICA HUMANGUT; do
	RUN_DIR="${index}_RUNDIR"
	RUN_DIR="${!RUN_DIR}"
	echo "Run dir: ${RUN_DIR}"

	echo -e "\tRef matrix: $RUN_DIR/matrices/$REF_MATRIX"
	cp $RUN_DIR/matrices/original/$REF_MATRIX $TMP_DIR/$REF_MATRIX

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo -e "\tSamples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo -e "\tConfig: ${CONFIG}"

	#Test TSP variants of NN
	for kmcomp in no_dm_nn no_dm_vptree_fix_masking no_dm_naive_vptree; do
		ORDER=$TMP_DIR/order_${index}_${kmcomp}.bin
		TOOL=$BMS_DIR/BMS_${kmcomp}/build/main_bitmatrixshuffle
		INPUT=$TMP_DIR/$REF_MATRIX
		OUTPUT=$TMP_DIR/block_${index}_${kmcomp}
		echo -e "\t$kmcomp"
		echo -e "\t\t:: Computing path TSP"

		#10 times
		for i in {0..9}; do
			echo -e "\t\t$i"

			export MEASURED_LOGFILE="$LOG_DIR/${index}_${kmcomp}_$i.txt"
	        export MEASURED_USAGEFILE="$USG_DIR/${index}_${kmcomp}_$i.txt"

			monitor_cmd $TOOL -i $INPUT -c $SAMPLES --header 49 -t $ORDER -z $OUTPUT -s 10000 --config-path $CONFIG -j "$MTC_DIR/metrics_${index}_${kmcomp}_$i.json"
		done
	done

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
