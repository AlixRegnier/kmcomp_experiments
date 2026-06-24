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
2. Edit file ``vars.sh`` with your own configuration
3. In each of your kmindex indexes:
  * Create a directory called ``original``
  * Copy all matrices in this directory
  * Reorder all matrices in ``your_run/matrices`` with ``kmcomp`` using a single permutation (see ``-t`` and ``-f`` options)
4. Run ``install_kmcomp.sh``

## Datasets

Used datasets:
|Dataset|#samples|Link|
|:--|--:|:--:|
|Ecoli|3,682|[link](https://doi.org/10.5281/zenodo.6577997)|
|Human gut metagenome|31,223|[link](https://arken.nmbu.no/~larssn/humgut/)|
|Senterica|150,000|[link](http://ftp.ebi.ac.uk/pub/databases/ENA2018-bacteria-661k)|

## Benchmark
*Note: you may need to install kmindex to benchmark query times*  
Once **setup** is complete: 

1. Run ``gen_results.sh``
1. Run ``gen_figures.sh``
