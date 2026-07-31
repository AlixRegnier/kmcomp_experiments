# kmcomp_experiments
Experiments for kmcomp paper

## Directories
In ``./scripts/figures/`` are all the scripts used to generate figures.  
In ``./scripts/results/`` are all the scripts used to generate results.  
In main directory, you can find multiple scripts mentioned in setup section.
## Requirements
You should try using latest of these.
```
apptainer
gcc
git
python3 (matplotlib plotnine)
```
## Setup
1. Build image using Apptainer
```bash
apptainer build container.sif recipe.def
```
2. Edit file ``vars.sh`` for customizing paths (notably indexes paths)
3. Run ``install.sh`` while being in same directory than the script

## Datasets

Used datasets:
|Dataset|#samples|Link|
|:--|--:|:--:|
|Ecoli|3,682|[link](https://doi.org/10.5281/zenodo.6577997)|
|Human gut metagenome|31,223|[link](https://arken.nmbu.no/~larssn/humgut/)|
|Senterica|150,000|[link](http://ftp.ebi.ac.uk/pub/databases/ENA2018-bacteria-661k)|

We indexed k-mers of size 26 with a false positive rate of 25%. Later on, queries false-positive are drastically reduced because when querying any 31-mer, we query its 26-mers.

k-mer matrices are already downloaded, decompressed and reordered back by pipeline. It uses this archive:
[https://zenodo.org/records/21509986](https://zenodo.org/records/21509986)

## Benchmark
*Note: you may need to install kmindex to benchmark query times*  
Once **setup** is complete: 

1. Run ``gen_results.sh``
1. Run ``gen_figures.sh``

## Note :warning:
The number of experiment repetitions is sometimes set to 1 to speed up the process, so the scripts used to generate the figures may be subject to variability in execution times. Notably for the order computation that can be long (so option ``-f`` is set instead of ``-t`` in some kmcomp commands.

