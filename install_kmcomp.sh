#!/bin/bash

source vars.sh

# Extract repo name without .git
for BRANCH in no_dm_nn no_dm_vptree bitpacking; do
  TARGET_DIR="$BMS_DIR/BMS_${BRANCH}"
  echo $TARGET_DIR
  git clone --branch "exp_$BRANCH" --single-branch "$KMCOMP_GIT" "$TARGET_DIR"

  apptainer exec --bind $TARGET_DIR --pwd $TARGET_DIR container.sif "./build.sh"
done
