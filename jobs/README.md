```
ssh <user>@stampede2.tacc.utexas.edu
cd $WORK
idev
module list
module load tacc-singularity
singularity pull docker://audiracmichelle/disperser
singularity shell disperser_latest.sif 
singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser_parallel_cluster.R -y 2015 -n 200
#sbatch jobs/launcher.sh
```
