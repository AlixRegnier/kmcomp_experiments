#!/bin/bash

source vars.sh

EXP_NAME="picompression"
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

	INDEX_DIR="${index}_INDEX"
	INDEX_DIR="${!INDEX_DIR}"

	remove_compression_files "$RUN_DIR"
	measure_size_raw "$RUN_DIR/matrices"
	size=$return_value

	echo "Run dir: ${RUN_DIR}"
	echo "Index dir: ${INDEX_DIR}"

	for block_size in 32 64 128 256 512 1024 2048 4096 8192; do
		block_size_bytes=$(echo "$block_size" | bc -l)
		echo "Block size: ${block_size}kb"

		#Compression
		drop_caches
		export MEASURED_LOGFILE="$LOG_DIR/logs.txt"
		export MEASURED_USAGEFILE="$USG_DIR/usage_compression_${index}_${block_size}kb.json"
		monitor_cmd /WORKS/aregnier/kmindex/kmindex_install/bin/kmindex compress -i $INDEX_DIR -n index_$index -l 3 -t $CPUS -b $block_size

		measure_size_compressed "$RUN_DIR/matrices"
		size_compressed=$return_value

		output_dir="$RUN_DIR/matrices/${block_size}kb_compressed/"
		mkdir -p $output_dir

		for i in {0..255}; do
			mv $RUN_DIR/matrices/blocks$i $output_dir
			mv $RUN_DIR/matrices/blocks$i.ef $output_dir
		done
		mv $RUN_DIR/compression.cfg $output_dir

		remove_compression_files "$RUN_DIR"

		#Picompression
		drop_caches
		export MEASURED_LOGFILE="$LOG_DIR/logs.txt"
		export MEASURED_USAGEFILE="$USG_DIR/usage_picompression_${index}_${block_size}kb.json"
		monitor_cmd /WORKS/aregnier/kmindex/kmindex_install/bin/kmindex compress -i $INDEX_DIR -n index_$index -r -e 10.0 -l 3 -t $CPUS -b $block_size

		measure_size_compressed "$RUN_DIR/matrices"
		size_picompressed=$return_value

		output_dir="$RUN_DIR/matrices/${block_size}kb_picompressed/"
		mkdir -p $output_dir

		for i in {0..255}; do
			mv $RUN_DIR/matrices/blocks$i $output_dir
			mv $RUN_DIR/matrices/blocks$i.ef $output_dir
		done
		mv $RUN_DIR/compression.cfg $output_dir
		mv $RUN_DIR/permutations.bin $output_dir

		remove_compression_files "$RUN_DIR"

		echo -e "{\n\t\"raw\": $size,\n\t\"compressed\": $size_compressed,\n\t\"picompressed\": $size_picompressed\n}" > "$TMP_DIR/size_${index}_${block_size}kb.json"
	done
done

#Clean temporary directory#rm -rf "${TMP_DIR}/*"

echo "Done!"

date
