#!/bin/bash
#SBATCH -J link_units               # job name
#SBATCH -N 4                        # number of nodes requested
#SBATCH -n 24                       # total number of tasks to run in parallel
#SBATCH -p skx-dev                  # queue (partition) 
#SBATCH -t 00:30:00                 # run time (hh:mm:ss) 

module load launcher
export LAUNCHER_WORKDIR=/work/08317/m1ch3ll3/stampede2/flaring_texas
export LAUNCHER_JOB_FILE=jobs/jobs_link_units
export LD_PRELOAD=""

${LAUNCHER_DIR}/paramrun
