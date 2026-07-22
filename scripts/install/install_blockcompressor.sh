#!/bin/bash

git clone --branch "main" --single-branch "$BLOCKCOMPRESSOR_GIT" "$BLOCKCOMPRESSOR_DIR"

apptainer exec --bind "$BLOCKCOMPRESSOR_DIR" --pwd "$BLOCKCOMPRESSOR_DIR" container.sif \
	bash -c './build.sh'

