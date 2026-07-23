#!/bin/bash

apptainer exec --bind "$(dirname $KMINDEX_DIR)" --pwd "$(dirname $KMINDEX_DIR)" container.sif \
	bash -c "
			git init "$KMINDEX_DIR" &&
			cd "$KMINDEX_DIR";
			git remote add origin "$KMINDEX_GIT" &&
			git fetch origin "$KMINDEX_COMMIT_HASH" &&
			git checkout FETCH_HEAD &&
			git submodule update --init --recursive &&
			./install.sh;
			cd - >/dev/null
		"
