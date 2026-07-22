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

EXP_NAME="query"
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
	MATRIX_DIR="${index}_MATRIXDIR"
	MATRIX_DIR="${!MATRIX_DIR}"

	echo "Run dir: ${RUN_DIR}"

	TOOL=$KMINDEX
	for size in 64kB 128kB 256kB 512kB 1MB 2MB 4MB 8MB; do
		echo ":: Block size: ${size}"
		cp $MATRIX_DIR/compression_${size}.cfg $MATRIX_DIR/compression.cfg
		for i in {0..255}; do
			cp $MATRIX_DIR/matrices/compression_${size}/blocks${i} $MATRIX_DIR/matrices/blocks${i}
			cp $MATRIX_DIR/matrices/compression_${size}/blocks${i}.ef $MATRIX_DIR/matrices/blocks${i}.ef
		done

		for n in 150 150000; do
			echo ":: Query size=${n}"
			for i in {0..4}; do
				echo ":: ${i}"

				OUTPUT=$TMP_DIR/${index}_query_result_${n}_${size}_${i}
				OUTPUT2=$TMP_DIR/${index}_query2_result_${n}_${size}_${i}
				QUERY=$QRY_DIR/f${n}_${i}.fasta

				export MEASURED_LOGFILE="$LOG_DIR/${index}_query_f${n}_${size}_${i}_uncompressed.txt"
				export MEASURED_USAGEFILE="$USG_DIR/${index}_query_f${n}_${size}_${i}_uncompressed.txt"
				monitor_cmd $TOOL query -i $RUN_DIR --uncompressed -z 6 -n index_${index} -o ${OUTPUT}_uncompressed -q $QUERY -t $CPUS

				export MEASURED_LOGFILE="$LOG_DIR/${index}_query2_f${n}_${size}_${i}_uncompressed.txt"
				export MEASURED_USAGEFILE="$USG_DIR/${index}_query2_f${n}_${size}_${i}_uncompressed.txt"
				monitor_cmd $TOOL query2 -i $RUN_DIR --uncompressed -z 6 -n index_${index} -o ${OUTPUT2}_uncompressed -q $QUERY -t $CPUS

				export MEASURED_LOGFILE="$LOG_DIR/${index}_query2_f${n}_${size}_${i}.txt"
				export MEASURED_USAGEFILE="$USG_DIR/${index}_query2_f${n}_${size}_${i}.txt"
				monitor_cmd $TOOL query2 -i $RUN_DIR -z 6 -n index_${index} -o $OUTPUT2 -q $QUERY -t $CPUS
			done
		done
	done
done

echo "Done!"

date
