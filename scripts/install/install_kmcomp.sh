#!/bin/bash

# Extract repo name without .git
for BRANCH in no_dm_nn no_dm_vptree_wlog no_dm_naive_vptree no_dm_vptree bitpacking; do
  TARGET_DIR="$KMCOMP_DIR/${BRANCH}"

  git clone --branch "exp_$BRANCH" --single-branch "$KMCOMP_GIT" "$TARGET_DIR"

  apptainer exec --bind $KMCOMP_DIR --pwd "$TARGET_DIR" container.sif \
  	bash -c './build.sh && ln -s main_bitmatrixshuffle ./build/kmcomp'
done
