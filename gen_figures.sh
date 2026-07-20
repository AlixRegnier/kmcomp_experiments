#!/bin/bash

for script in ./scripts/figures/*.py; do
    python3 $script
    echo $script
done
