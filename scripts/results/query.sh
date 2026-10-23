#!/bin/bash

source vars.sh

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

#rm -rf "${TMP_DIR}/*"

date
echo "Starting"
echo "Creating random queries..."

mkdir -p $EXP_DIR/query

for n in 150 150000; do
	for i in {0..19}; do
		#<nucleotides> <nb nucleotide per row>
		python3 $SCRIPT_DIR/scripts/generate_fasta.py $n 100 > $EXP_DIR/query/f${n}nt_$i.fasta
	done
done

#Indexes
for index in ECOLI SENTERICA HUMANGUT; do
	RUN_DIR="${index}_RUNDIR"
	RUN_DIR="${!RUN_DIR}"

	INDEX_DIR="${RUN_DIR}_index"

	echo "Run dir: ${RUN_DIR}"

	TOOL=$KMINDEX
	for size in 32 64 128 256 512 1024 2048 4096 8192; do
		echo "Block size: ${size}"
		echo "Loading matrices..."
		load_compressed "$RUN_DIR" "${size}kb"
		echo "Matrices loaded"

		for n in 150 150000; do
			echo "Query size=${n}"
			echo "Repeating (x20)"
			for i in {0..19}; do
				OUTPUT=$TMP_DIR/${index}_query_result_${n}_${size}_${i}
				OUTPUT2=$TMP_DIR/${index}_query2_result_${n}_${size}_${i}
				QUERY=$EXP_DIR/query/f${n}nt_$i.fasta

				#Avoid repeating queries on uncompressed index
				if [ $size -eq 32 ]; then
					export MEASURED_LOGFILE="$LOG_DIR/${index}_query_f${n}_${size}_${i}_uncompressed.txt"
					export MEASURED_USAGEFILE="$USG_DIR/${index}_query_f${n}_${size}_${i}_uncompressed.txt"
					drop_caches
					monitor_cmd $TOOL query -i $INDEX_DIR --uncompressed -z 6 -n index_${index} -o ${OUTPUT}_uncompressed -q $QUERY -t $CPUS --fast --single

					export MEASURED_LOGFILE="$LOG_DIR/${index}_query2_f${n}_${size}_${i}_uncompressed.txt"
					export MEASURED_USAGEFILE="$USG_DIR/${index}_query2_f${n}_${size}_${i}_uncompressed.txt"
					drop_caches
					monitor_cmd $TOOL query2 -i $INDEX_DIR --uncompressed -z 6 -n index_${index} -o ${OUTPUT2}_uncompressed -q $QUERY -t $CPUS --single
				fi

				export MEASURED_LOGFILE="$LOG_DIR/${index}_query2_f${n}_${size}_${i}.txt"
				export MEASURED_USAGEFILE="$USG_DIR/${index}_query2_f${n}_${size}_${i}.txt"
				drop_caches
				monitor_cmd $TOOL query2 -i $INDEX_DIR -z 6 -n index_${index} -o $OUTPUT2 -q $QUERY -t $CPUS --single
			done
		done
	done

	#Clean temporary directory
	#rm -rf "${TMP_DIR}/*"
done

echo "Done!"

date
