n <- 200
c <- seq(n)
text <- c()
for(y in seq(2015,2020)) {
  text <- c(text, paste(
    "singularity exec $SCRATCH/disperser_latest.sif Rscript --vanilla jobs/polygon_parcels/polygon_parcels.R", 
    "-y", y, 
    "-n", n, 
    "-c", c, 
    "-w '/work/08317/m1ch3ll3/stampede2/flaring_texas'\n", collapse = ""))
}
cat(text, file = "./jobs_polygon_parcels")
