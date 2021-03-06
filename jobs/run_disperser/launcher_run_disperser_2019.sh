#!/bin/sh
#SBATCH -J 2019_run_disperser       # job name
#SBATCH -N 24                       # number of nodes requested
#SBATCH -n 24                       # total number of tasks to run in parallel
#SBATCH -p skx-normal               # queue (partition) 
#SBATCH -t 01:30:00                 # run time (hh:mm:ss) 

module load launcher
export LAUNCHER_WORKDIR=/work/08317/m1ch3ll3/stampede2/flaring_texas
export LAUNCHER_JOB_FILE=jobs/run_disperser/jobs_run_disperser_2019
export LD_PRELOAD=""

${LAUNCHER_DIR}/paramrun

