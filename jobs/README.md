```
ssh <user>@stampede2.tacc.utexas.edu
cd $WORK
module list
module load tacc-singularity

idev
#singularity pull docker://audiracmichelle/disperser
singularity shell disperser_latest.sif 
singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser_parallel_cluster.R -y 2016 -n 200 -c 100 -w <wkdir>
#"/work/08317/m1ch3ll3/stampede2/flaring_texas"
#sbatch jobs/launcher.sh
```
