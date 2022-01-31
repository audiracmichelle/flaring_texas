#!/bin/sh
#SBATCH -J run_disperser            # job name
#SBATCH -N 1                        # number of nodes requested
#SBATCH -n 100                       # total number of tasks to run in parallel
#SBATCH -p skx-dev                  # queue (partition) 
#SBATCH -t 04:00:00                 # run time (hh:mm:ss) 

module load tacc-singularity

export LD_PRELOAD=""

module load launcher

export LD_PRELOAD=""
export LAUNCHER_WORKDIR=/work/08317/m1ch3ll3/stampede2/flaring_texas
export LAUNCHER_JOB_FILE=jobs/jobs_run_disperser_2015

${LAUNCHER_DIR}/paramrun

