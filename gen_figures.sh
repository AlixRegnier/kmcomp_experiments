#!/bin/bash

DIR=./scripts/figures
mkdir -p $DIR

for script in $DIR/*.py; do
    python3 $script
    echo $script
done