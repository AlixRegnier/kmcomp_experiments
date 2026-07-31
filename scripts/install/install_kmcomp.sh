#!/bin/bash

# Extract repo name without .git
for BRANCH in no_dm_nn no_dm_vptree_wlog no_dm_naive_vptree bitpacking; do
  TARGET_DIR="$KMCOMP_DIR/${BRANCH}"

  git clone --branch "exp_$BRANCH" --single-branch "$KMCOMP_GIT" "$TARGET_DIR"

  apptainer exec --bind $KMCOMP_DIR --pwd "$TARGET_DIR" container.sif \
  	bash -c './build.sh && ln -s main_bitmatrixshuffle ./build/kmcomp'
done

#For no_dm_vptree branch do an exception to force building with metrics enabled
BRANCH=no_dm_vptree
TARGET_DIR="$KMCOMP_DIR/${BRANCH}"
git clone --branch "exp_$BRANCH" --single-branch "$KMCOMP_GIT" "$TARGET_DIR"

apptainer exec --bind $KMCOMP_DIR --pwd "$TARGET_DIR" container.sif \
        bash -c '
			mkdir -p build
			cd build
			cmake .. -DCMAKE_BUILD_TYPE=Release -DKMCOMP_BUILD_MAIN=true -DKMCOMP_METRICS=true
			make -j
			cd - >/dev/null
		'
