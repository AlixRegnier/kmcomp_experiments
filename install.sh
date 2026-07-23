#!/bin/bash

if [ ! -f vars.sh ]; then
	echo "ERROR: This script must be run with vars.sh in the working directory !"
	exit 2
fi

source vars.sh

for f in $MAIN_DIR/scripts/install/*; do
	bash $f
done
