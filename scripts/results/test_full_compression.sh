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


EXP_NAME=compression
source ./vars.sh

TMP_DIR=/WORKS/aregnier/Exp/bench/tmp_dir/$EXP_NAME
LOG_DIR=/WORKS/aregnier/Exp/bench/logs/$EXP_NAME
USG_DIR=/WORKS/aregnier/Exp/bench/usage/$EXP_NAME
MTC_DIR=/WORKS/aregnier/Exp/bench/metrics/$EXP_NAME

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

	TOOL=$KMINDEX
	export MEASURED_LOGFILE="$LOG_DIR/${index}.txt"
	export MEASURED_USAGEFILE="$USG_DIR/${index}.txt"
	monitor_cmd $TOOL compress -i $RUN_DIR -n index_${index} -b 8 -r -l 3 -t $CPUS

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"

done

echo "Done!"

date
