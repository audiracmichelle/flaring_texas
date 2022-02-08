# weight_parcels_parallel
weight_parcels_parallel <- function(
  input.refs, 
  hysp_dir, 
  mc.cores = parallel::detectCores()
  ){
  run_X <- lapply(1:nrow(input.refs), function(r) input.refs[r])
  
  parallel::mclapply(X = run_X, 
                     FUN = run_FUN, 
                     hysp_dir = hysp_dir, 
                     mc.cores = mc.cores)
}

# run_FUN
run_FUN <- function(
  X, 
  hysp_dir = hysp_dir, 
  proc_dir = proc_dir
  ){
  X_tag <- paste("ID", X$ID, 
                 '| start_day', format(X$start_day, format = "%Y-%m-%d"), 
                 '| start_hour', X$start_hour)
  print(paste("processing X:", X_tag))

  #### read hysp file
  hysp_dir_yr <- file.path(hysp_dir, X$year)
  hysp_dir_mo <- file.path(hysp_dir_yr,
                           formatC(month(X$start_day), width = 2, flag = '0'))
  output_file <- path.expand(file.path(hysp_dir_mo,
                                       paste0("hyspdisp_", 
                                              X$ID, "_", 
                                              X$start_day, "_", 
                                              formatC(X$start_hour, width = 2, format = "d", flag = "0"),
                                              ".fst")))

  #### modifying output file
  if(!file.exists(output_file)) {
    out <- paste("Error hysplit not run for X:", X_tag)
    print(out)
    return(out)
  }
  
  print(paste("Modifying output file:", output_file))
  
  disp_df <- read.fst(output_file)
  disp_df <- na.omit(disp_df)
  disp_df$W <- X$flares
  write.fst(disp_df, output_file)
  
  out <- paste("Weights written to", output_file)
  print(out)
  return(out)
}