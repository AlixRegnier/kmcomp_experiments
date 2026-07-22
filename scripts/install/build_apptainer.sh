#!/bin/bash

if [ ! -f "$APPTAINER_IMAGE" ]; then
	apptainer build "$APPTAINER_IMAGE" "$MAIN_DIR/recipe.def"
else
	echo "Image already exists"
fi
