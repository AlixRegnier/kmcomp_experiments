#!/bin/bash

export KMCOMP_GIT=https://github.com/AlixRegnier/kmcomp.git
export KMINDEX=/path/to/kmindex/binary
export APPTAINER_IMAGE=./container.sif

#Path given to apptainer to mount them (enable access to these paths)
export APPTAINER_BIND_DIRS=/first/path,/second/path/

export CPUS=1
export REF_MATRIX=matrix_1.cmbf

#Runs dirs
INDEXES_DIR=/path/to/indexes
export ECOLI_RUNDIR=$INDEXES_DIR/ecoli/index
export SENTERICA_RUNDIR=$INDEXES_DIR/senterica/index
export HUMANGUT_RUNDIR=$INDEXES_DIR/humangut/index

export EXP_DIR=.
export QRY_DIR=/path/to/query/dir

export BMS_DIR=./kmcomp