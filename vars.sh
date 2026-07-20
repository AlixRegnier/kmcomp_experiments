#!/bin/bash

export KMCOMP_GIT=https://github.com/AlixRegnier/kmcomp.git
export KMINDEX=/scratch/aregnier/kmindex/kmindex_install/bin/kmindex

#Expecting an absolute path
export SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export APPTAINER_IMAGE=$SCRIPT_DIR/container.sif


export CPUS=1
export REF_MATRIX=matrix_1.cmbf

#Runs dirs
INDEXES_DIR=/WORKS/aregnier/Exp/SOTAcomparison/kmindex/
export ECOLI_RUNDIR=$INDEXES_DIR/ecoli/
export SENTERICA_RUNDIR=$INDEXES_DIR/senterica/
export HUMANGUT_RUNDIR=$INDEXES_DIR/humangut/

#Path given to apptainer to mount them (enable access to these paths)
export APPTAINER_BIND_DIRS=$(dirname $KMINDEX),$SCRIPT_DIR,$INDEXES_DIR

export EXP_DIR=.
export QRY_DIR=./query

export BMS_DIR=$SCRIPT_DIR/kmcomp
