#!/bin/bash

source ./vars.sh

for s in block compression permutation query reorder subsample; do
	apptainer exec --bind $APPTAINER_BIND_DIRS $APPTAINER_IMAGE bash ./scripts/results/${s}.sh
done
