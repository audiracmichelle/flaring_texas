c <- seq(100)
cat(paste("singularity exec disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y 2015 -n 100", 
          "-c", 
          c, 
          "-w '/work/08317/m1ch3ll3/stampede2/flaring_texas'", collapse = "\n"), 
    file = "./jobs_run_disperser")
 