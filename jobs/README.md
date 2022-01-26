```
ssh <user>@stampede2.tacc.utexas.edu
cd $WORK
module list
module load tacc-singularity/3.7.0

idev
#singularity pull docker://audiracmichelle/disperser
singularity shell disperser_latest.sif 

singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y 2016 -n 1000 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"
#sbatch jobs/launcher.sh
```
Rscript --vanilla jobs/run_disperser.R -y 2016 -n 100 -c 25 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"

#squeue -u m1ch3ll3
#command search: ctr+r sq

singularity exec disperser_latest.sif Rscript --vanilla jobs/link_units.R -y 2015 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"

