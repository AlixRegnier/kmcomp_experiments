#!/bin/bash

source vars.sh

EXP_NAME="query_fulgor"
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
echo "Starting"
echo "Creating random queries..."

mkdir -p $EXP_DIR/query

#Indexes
for index in ecoli senterica humangut; do

	INDEX_DIR="/WORKS/aregnier/Exp/SOTAcomparison/fulgor/$index"
	echo "Run dir: ${INDEX_DIR}"

	TOOL=/scratch/aregnier/soft/bin/fulgor
	for n in 150 150000; do
		echo "Query size=${n}"
		echo "Repeating (x20)"
		for i in {0..19}; do
			QUERY=$EXP_DIR/query/f${n}nt_$i.fasta

			OUTPUT=$TMP_DIR/${index}_query_result_${n}_${i}_uncompressed.txt
			export MEASURED_LOGFILE="$LOG_DIR/${index}_query_f${n}_${i}_uncompressed.txt"
			export MEASURED_USAGEFILE="$USG_DIR/${index}_query_f${n}_${i}_uncompressed.json"
			drop_caches
			monitor_cmd $TOOL pseudoalign -i "$INDEX_DIR/index.fur" -t $CPUS -q $QUERY -o $OUTPUT

			OUTPUT=$TMP_DIR/${index}_query_result_${n}_${i}_md.txt
			export MEASURED_LOGFILE="$LOG_DIR/${index}_query_f${n}_${i}_md.txt"
			export MEASURED_USAGEFILE="$USG_DIR/${index}_query_f${n}_${i}_md.json"
			drop_caches
			monitor_cmd $TOOL pseudoalign -i "$INDEX_DIR/index.mdfur" -t $CPUS -q $QUERY -o $OUTPUT
		done
	done
done

echo "Done!"

date
