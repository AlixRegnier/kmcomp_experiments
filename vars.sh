#!/bin/bash

abspath() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) realpath -m -- "$PWD/$1" ;;
    esac
}

export MAIN_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

#Repo variables
export KMCOMP_GIT="https://github.com/AlixRegnier/kmcomp.git"
export KMCOMP_DIR=$(abspath "$MAIN_DIR/kmcomp")

export KMINDEX_DIR="https://github.com/tlemane/kmindex.git"
export KMINDEX_COMMIT_HASH="fede5fa6959b8d5cde827157ed39bf2bbde284a1"
export KMINDEX_DIR=$(abspath "$MAIN_DIR/kmindex")

export BLOCKCOMPRESSOR_GIT="https://github.com/AlixRegnier/blockcompressor.git"
export BLOCKCOMPRESSOR_DIR=$(abspath "$MAIN_DIR/BlockCompressor")

export APPTAINER_IMAGE=$(abspath "$MAIN_DIR/container.sif")

#Runs dirs
INDEXES_DIR=$(abspath "$MAIN_DIR/data")
export ECOLI_RUNDIR="$INDEXES_DIR/ecoli"
export SENTERICA_RUNDIR="$INDEXES_DIR/senterica"
export HUMANGUT_RUNDIR="$INDEXES_DIR/humangut"

#Apptainer mount directories (directories need to be spaced with ',')
export APPTAINER_BIND_DIRS="$INDEXES_DIR"

#Experimental variables
export REF_MATRIX=matrix_1.cmbf #Reference matrix to use
export EXP_DIR=$(abspath "$MAIN_DIR/exps")
export QRY_DIR=$(abspath "$MAIN_DIR/query")
export QRY_CPUS=1

