n <- 100
c <- seq(n)
for(y in seq(2015,2020)) {
  cat(paste("singularity exec $SCRATCH/disperser_latest.sif Rscript --vanilla jobs/run_disperser.R -y", 
            y, 
            "-n", n, 
            "-c", c, 
            "-w '/work/08317/m1ch3ll3/stampede2/flaring_texas'\n", collapse = ""), 
      file = paste0("./jobs_run_disperser_", y))
}
