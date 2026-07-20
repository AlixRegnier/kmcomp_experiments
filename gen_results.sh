#!/bin/bash

source ./vars.sh

for s in block; do #compression permutation query reorder subsample; do
	apptainer exec --bind $APPTAINER_BIND_DIRS $SCRIPT_DIR/container.sif bash ./scripts/results/${s}.sh
done
