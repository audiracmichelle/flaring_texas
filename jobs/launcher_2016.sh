#!/bin/bash
#SBATCH -J run_disperser_parallel            # job name
#SBATCH -N 1                        # number of nodes requested
#SBATCH -n 1                       # total number of tasks to run in parallel
#SBATCH -p skx                  # queue (partition) 
#SBATCH -t 08:00:00                 # run time (hh:mm:ss) 

module load tacc-singularity

export LD_PRELOAD=""

srun singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser_parallel_cluster.R -y 2016 -n 1000 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"
