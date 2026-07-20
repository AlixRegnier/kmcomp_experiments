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
    echo -e "{\n\t\"command\": \"$MEASURED_COMMAND\",\n\t\"time(s)\": $MEASURED_WALL_TIME,\n\t\"memory(KB)\": $MEASURED_RSS_MEMORY\n}" > "$MEASURED_USAGEFILE"
    export MEASURED_WALL_TIME="NaN"
    export MEASURED_RSS_MEMORY="NaN"
    export MEASURED_COMMAND="NaN"

    echo "\$\$\$ $@"
}

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

	echo -e "\tRef matrix: $RUN_DIR/matrices/${index}_ref.cmbf"
	cp $RUN_DIR/matrices/$REF_MATRIX $TMP_DIR/${index}_ref.cmbf

	SAMPLES=$(cat $RUN_DIR/kmtricks.fof | wc -l)
	echo -e "\tSamples: ${SAMPLES}"

	CONFIG=$TMP_DIR/config_${index}.cfg
	echo -e "\tConfig: ${CONFIG}"

	ORDER=$TMP_DIR/order_${index}.bin
	echo -e "\t:: Computing path TSP"
	$BMS/BMS_no_dm_vptree/build/main_bitmatrixshuffle -i $TMP_DIR/${index}_ref.cmbf -c $SAMPLES --header 49 -z $TMP_DIR/block_${index}_ref -t $ORDER --config-path $CONFIG >/dev/null
	echo "\$\$\$ $BMS/BMS_no_dm_vptree/build/main_bitmatrixshuffle -i $TMP_DIR/${index}_ref.cmbf -c $SAMPLES -z $TMP_DIR/block_${index}_ref -t $ORDER >/dev/null"
	echo -e "\t\tComputed order to: $ORDER"
	echo -e "\t:: Reordering reference matrix"

	#Test reordering variants
	for kmcomp in bitpacking no_dm_vptree_fix_masking; do
		TOOL=$BMS/BMS_${kmcomp}/build/main_bitmatrixshuffle
		INPUT=$TMP_DIR/${index}_ref.cmbf
		OUTPUT=$TMP_DIR/xxx
		echo -e "\t\t$kmcomp"
		export MEASURED_LOGFILE="$LOG_DIR/${index}_${kmcomp}_ref.txt"
        export MEASURED_USAGEFILE="$USG_DIR/${index}_${kmcomp}_ref.txt"

		monitor_cmd $TOOL -i $INPUT -z $OUTPUT -c $SAMPLES --header 49 -f $ORDER -j "$MTC_DIR/metrics_${index}_${kmcomp}_ref.json" --config-path $CONFIG
	done

	#Reorder each matrices (ref+7 to estimate global x32)
	for kmcomp in bitpacking no_dm_vptree; do
		TOOL=$BMS/BMS_${kmcomp}/build/main_bitmatrixshuffle
		echo -e "\t\t$kmcomp"

		for i in {0..6}; do
			echo -e "\t\t$i"
			cp $RUN_DIR/matrices/matrix_${i}.cmbf $TMP_DIR/matrix_${i}.cmbf
			export MEASURED_LOGFILE="$LOG_DIR/${index}_${kmcomp}_${i}.txt"
	                export MEASURED_USAGEFILE="$USG_DIR/${index}_${kmcomp}_${i}.txt"
			#here
			monitor_cmd $TOOL -i $TMP_DIR/matrix_${i}.cmbf -z $TMP_DIR/xxx -c $SAMPLES --header 49 -f $ORDER -j "$MTC_DIR/metrics_${index}_${kmcomp}_${i}.json" --config-path $CONFIG
		done
	done

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
