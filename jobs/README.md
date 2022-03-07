```
ssh <user>@stampede2.tacc.utexas.edu
cd $WORK
module list
module load tacc-singularity
module spider tacc-singularity/3.7.2

idev
#singularity pull docker://audiracmichelle/disperser

singularity pull docker://ubuntu:xenial
cp disperser_latest.sif $SCRATCH/
singularity exec $SCRATCH/ubuntu-xenial.simg echo "This also works"

singularity shell disperser_latest.sif 

singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y 2016 -n 1000 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"
#sbatch jobs/launcher.sh
```
Rscript --vanilla jobs/run_disperser.R -y 2016 -n 100 -c 25 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"

#squeue -u m1ch3ll3
#command search: ctr+r sq

singularity exec disperser_latest.sif Rscript --vanilla jobs/link_units.R -y 2015 -w "/work/08317/m1ch3ll3/stampede2/flaring_texas"


singularity exec $SCRATCH/disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y 2015 -n 100 -c 1 -w '/work/08317/m1ch3ll3/stampede2/flaring_texas'


----------------------------------------------------------------------------
  tacc-singularity: tacc-singularity/3.7.2
----------------------------------------------------------------------------
    Description:
      Application and environment virtualization


    This module can be loaded directly: module load tacc-singularity/3.7.2

    Help:
      Singularity is not installed and should not be run on the login nodes.
      
      A functional Singularity module is available on the compute nodes. Submit
      Singularity job scripts to the queue with 'sbatch'. If you would like to run
      Singularity interactively, please start an interactive session with 'idev'.
      
      [login]\\$ idev
      [compute]\\$ singularity run container.img
      
      #############################################################################
      
      Images and layers are now cached to $STOCKYARD2/singularity_cache. All images
      created with singularity pull will be deposited to that location, and can
      only be controlled by changing the cache location. We recommend running with
      the container url
      
        singularity exec docker://ubuntu:xenial echo "This works"
      
      or copying the pulled container to a different location
      
        singularity pull docker://ubuntu:xenial
        cp $STOCKYARD2/singularity_cache/ubuntu-xenial.simg $SCRATCH/
        singularity exec $SCRATCH/ubuntu-xenial.simg echo "This also works"
      
      #############################################################################
      
                     OverlayFS is disabled on tacc-singularity
      
      tacc-singularity utilizes the more secure underlay method automatically mount
      shared filesystems and any user-specified locations. This means you no longer
      need to include directories like
      
        /work and /scratch
      
      in your images, but still cannot utilize advanced overlay-specific features.
      
      #############################################################################
      
      Additional Documentation
      
      - Singularity Main - https://sylabs.io/singularity
      - Containers@TACC  - https://containers-at-tacc.readthedocs.io/en/latest/
      - MPI with Singularity - https://github.com/TACC/tacc-containers
      
      Version 3.7.2


ls main/output/hysplit/2015/07 | wc
ls main/output/hysplit/2015/08 | wc
ls main/output/hysplit/2015/09 | wc
ls main/output/hysplit/2015/10 | wc
ls main/output/hysplit/2015/11 | wc
ls main/output/hysplit/2015/12 | wc

ls main/output/hysplit/2016/01 | wc
ls main/output/hysplit/2016/02 | wc
ls main/output/hysplit/2016/03 | wc
ls main/output/hysplit/2016/04 | wc
ls main/output/hysplit/2016/05 | wc
ls main/output/hysplit/2016/06 | wc
ls main/output/hysplit/2016/07 | wc
ls main/output/hysplit/2016/08 | wc
ls main/output/hysplit/2016/09 | wc
ls main/output/hysplit/2016/10 | wc
ls main/output/hysplit/2016/11 | wc
ls main/output/hysplit/2016/12 | wc

ls main/output/hysplit/2017/01 | wc
ls main/output/hysplit/2017/02 | wc
ls main/output/hysplit/2017/03 | wc
ls main/output/hysplit/2017/04 | wc
ls main/output/hysplit/2017/05 | wc
ls main/output/hysplit/2017/06 | wc
ls main/output/hysplit/2017/07 | wc
ls main/output/hysplit/2017/08 | wc
ls main/output/hysplit/2017/09 | wc
ls main/output/hysplit/2017/10 | wc
ls main/output/hysplit/2017/11 | wc
ls main/output/hysplit/2017/12 | wc

ls main/output/hysplit/2018/01 | wc
ls main/output/hysplit/2018/02 | wc
ls main/output/hysplit/2018/03 | wc
ls main/output/hysplit/2018/04 | wc
ls main/output/hysplit/2018/05 | wc
ls main/output/hysplit/2018/06 | wc
ls main/output/hysplit/2018/07 | wc
ls main/output/hysplit/2018/08 | wc
ls main/output/hysplit/2018/09 | wc
ls main/output/hysplit/2018/10 | wc
ls main/output/hysplit/2018/11 | wc
ls main/output/hysplit/2018/12 | wc

ls main/output/hysplit/2019/01 | wc
ls main/output/hysplit/2019/02 | wc
ls main/output/hysplit/2019/03 | wc
ls main/output/hysplit/2019/04 | wc
ls main/output/hysplit/2019/05 | wc
ls main/output/hysplit/2019/06 | wc
ls main/output/hysplit/2019/07 | wc
ls main/output/hysplit/2019/08 | wc
ls main/output/hysplit/2019/09 | wc
ls main/output/hysplit/2019/10 | wc
ls main/output/hysplit/2019/11 | wc
ls main/output/hysplit/2019/12 | wc

ls main/output/hysplit/2020/01 | wc
ls main/output/hysplit/2020/02 | wc
ls main/output/hysplit/2020/03 | wc
ls main/output/hysplit/2020/04 | wc
ls main/output/hysplit/2020/05 | wc
ls main/output/hysplit/2020/06 | wc
ls main/output/hysplit/2020/07 | wc
ls main/output/hysplit/2020/08 | wc
ls main/output/hysplit/2020/09 | wc
ls main/output/hysplit/2020/10 | wc
ls main/output/hysplit/2020/11 | wc
ls main/output/hysplit/2020/12 | wc


