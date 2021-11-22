ssh <user>@stampede2.tacc.utexas.edu
cd $WORK
idev
module list
module load tacc-singularity
singularity pull docker://audiracmichelle/disperser
singularity shell disperser_latest.sif 
singularity exec disperser_latest.sif Rscript --vanilla jobs/disperser_scirpt.r -y 2015
sbatch jobs/launcher.sh