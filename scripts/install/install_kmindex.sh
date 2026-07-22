#!/bin/bash

git init "$KMINDEX_DIR"
cd "$KMINDEX_DIR"
git remote add origin "$KMINDEX_GIT"
git fetch origin "$KMINDEX_COMMIT_HASH"
git checkout FETCH_HEAD
git submodule update --init --recursive
cd - >/dev/null

apptainer exec --bind "$KMINDEX_DIR" --pwd "$KMINDEX_DIR" container.sif \
  	bash -c './install.sh'

