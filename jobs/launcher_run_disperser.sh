#!/bin/bash
#SBATCH -J run_disperser_parallel            # job name
#SBATCH -N 1                        # number of nodes requested
#SBATCH -n 2                       # total number of tasks to run in parallel
#SBATCH -p skx-normal                  # queue (partition) 
#SBATCH -t 08:00:00                 # run time (hh:mm:ss) 

module load tacc-singularity

export LD_PRELOAD=""

module load launcher

export LD_PRELOAD=""
export LAUNCHER_WORKDIR=/work/08317/m1ch3ll3/stampede2/flaring_texas
export LAUNCHER_JOB_FILE=jobs/jobs_run_disperser

${LAUNCHER_DIR}/paramrun