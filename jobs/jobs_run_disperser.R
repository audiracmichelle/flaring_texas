c <- seq(20)
for(y in seq(2015,2020)) {
  cat(paste("singularity exec $SCRATCH/disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y", 
            y, 
            "-n 20", 
            "-c", 
            c, 
            "-w '/work/08317/m1ch3ll3/stampede2/flaring_texas'", collapse = "\n"), 
      file = paste0("./jobs_run_disperser_", y))
}
