#!/bin/bash

source vars.sh

# Extract repo name without .git
for BRANCH in no_dm_nn no_dm_vptree_zstd_wlog no_dm_naive_vptree no_dm_vptree_fix_masking bitpacking; do
  TARGET_DIR="$BMS_DIR/BMS_exp_${BRANCH}"

  git clone --branch "$BRANCH" --single-branch "$KMCOMP_GIT" "$TARGET_DIR"

  apptainer exec --bind $BMS_DIR container.sif "bash ./build.sh"
done