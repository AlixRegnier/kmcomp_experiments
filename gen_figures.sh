#!/bin/bash

source vars.sh

mkdir -p ./figures

for script in ./scripts/figures/*.py; do
    echo $script
    python3 $script
done
