# polygon_parcels_parallel
polygon_parcels_parallel <- function(
  input.refs, 
  sf, 
  hysp_dir, 
  mc.cores = parallel::detectCores()
){
  run_X <- lapply(1:nrow(input.refs), function(r) input.refs[r])
  
  polygon_parcels <- parallel::mclapply(X = run_X, 
                     FUN = run_polygon_parcels, 
                     sf = sf, 
                     hysp_dir = hysp_dir, 
                     mc.cores = mc.cores)
  rbindlist(polygon_parcels)
}

# run_polygon_parcels
run_polygon_parcels <- function(
  X, 
  sf, 
  hysp_dir = hysp_dir
){
  X_tag <- paste("ID", X$ID, 
                 '| start_day', format(X$start_day, format = "%Y-%m-%d"), 
                 '| start_hour', X$start_hour)
  print(paste("processing X:", X_tag))
  
  #### read hysp file
  hysp_dir_yr <- file.path(hysp_dir, X$year)
  hysp_dir_mo <- file.path(hysp_dir_yr,
                           formatC(month(X$start_day), width = 2, flag = '0'))
  hysp_file <- path.expand(file.path(hysp_dir_mo,
                                       paste0("hyspdisp_", 
                                              X$ID, "_", 
                                              X$start_day, "_", 
                                              formatC(X$start_hour, width = 2, 
                                                      format = "d", flag = "0"),
                                              ".fst")))
  #### linking output
  if(!file.exists(hysp_file)) {
    out <- stop("Error hysplit not run for X:", X_tag)
  }
  
  print(paste("Linking output from file:", hysp_file))
  
  disp_df <- read.fst(hysp_file, as.data.table = TRUE)
  disp_df <- na.omit(disp_df)
  proj <- "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m"
  
  #parcels
  parcels <- disp_df[, .(lon, lat)]
  parcels <- SpatialPoints(coords = parcels, 
                           proj4string = CRS( "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  parcels <- st_as_sf(parcels)
  parcels <- st_transform(parcels, proj)
  
  #polygons
  polygon_parcels <- st_transform(sf, proj)
  polygon_parcels$count <- lengths(st_intersects(polygon_parcels, parcels))
  polygon_parcels %<>% 
    st_drop_geometry() %>% 
    filter(count > 0)
  polygon_parcels <- rbind(polygon_parcels, 
                           data.frame(id="out_polygons", count = 1200 - sum(polygon_parcels$count)))
  polygon_parcels$weight <- X$flares
  polygon_parcels$source <- X$ID
  polygon_parcels$start_day <- X$start_day
  polygon_parcels$start_hour <- X$start_hour
  polygon_parcels<- data.table(polygon_parcels, stringsAsFactors = FALSE)

  print(paste("linked output from", hysp_file))
  return(polygon_parcels)
}



