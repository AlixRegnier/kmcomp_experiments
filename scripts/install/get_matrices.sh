#!/bin/bash

source vars.sh

wget "https://zenodo.org/records/21509986/files/matrices.tar"
tar xf matrices.tar

for index in ecoli senterica humangut; do
        echo ":: $index"
        columns=$(wc -l "$INDEXES_DIR"/$index/kmtricks.fof)

        for e in {0..6} 255; do
                echo $e

		#Decompress matrix
                "$BLOCKCOMPRESSOR_DIR"/build/block_decompressor_bin \
			"$INDEXES_DIR"/$index/config.cfg \
			"$INDEXES_DIR"/$index/matrices/reordered/block_${e} \
			"$INDEXES_DIR"/$index/matrices/reordered/block_${e}.ef \
			49 \
			"$INDEXES_DIR"/$index/matrices/reordered/matrix_${e}.cmbf

		mkdir -p "$INDEXES_DIR"/$index/matrices/original
                cp "$INDEXES_DIR"/$index/matrices/reordered/matrix_${e}.cmbf "$INDEXES_DIR"/$index/matrices/original/matrix_${e}.cmbf

		#Reorder matrix inplace in 'original' directory
                "$KMCOMP_DIR"/no_dm_vptree/build/kmcomp \
			-i "$INDEXES_DIR"/$index/matrices/original/matrix_${e}.cmbf \
			-c $columns \
			-f "$INDEXES_DIR"/$index/order.bin \
			-r \
			-b 65536 \
			--header 49 \
			--config-path "$INDEXES_DIR"/$index/config.cfg

		#Compress matrix
               	"$KMCOMP_DIR"/no_dm_vptree/build/kmcomp \
			-i "$INDEXES_DIR"/$index/matrices/original/matrix_${e}.cmbf \
			-c $columns \
			-n \
			-z "$INDEXES_DIR"/$index/matrices/original/block_$e \
			-b 65536 \
			--header 49 \
			--config-path "$INDEXES_DIR"/$index/config.cfg

        done
done
