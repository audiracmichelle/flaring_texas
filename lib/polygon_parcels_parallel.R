library(sp)
library(raster)
library(rgeos)

# polygon_parcels_parallel
polygon_parcels_parallel <- function(
  mc.cores = parallel::detectCores(), 
  input.refs, 
  polygons_sf, 
  hysp_dir, 
  res.link = 12000
){
  run_X <- lapply(1:nrow(input.refs), function(r) input.refs[r])
  polygon_parcels <- parallel::mclapply(FUN = run_polygon_parcels, 
                     mc.cores = mc.cores,
                     X = run_X, 
                     polygons_sf = polygons_sf, 
                     hysp_dir = hysp_dir, 
                     res.link = res.link)
  rbindlist(polygon_parcels)
}

# run_polygon_parcels
run_polygon_parcels <- function(
  X, 
  polygons_sf, 
  hysp_dir = hysp_dir, 
  res.link = 12000
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
  
  #polygons
  get_polygon_counts <- function(parcels, proj, polygons_sf) {
    parcels <- st_as_sf(parcels)
    parcels <- st_transform(parcels, proj)
    polygon_parcels <- st_transform(polygons_sf, proj)
    polygon_parcels$count <- lengths(st_intersects(polygon_parcels, parcels))
    polygon_parcels %<>% 
      st_drop_geometry() %>% 
      filter(count > 0)
    rbind(polygon_parcels, data.frame(id="outside_polygons", count = 1200 - sum(polygon_parcels$count)))
  }
  
  get_polygon_hyads <- function(parcels, proj, polygons_sf, res.link) {
    parcels <- spTransform(parcels, proj)
    polygons_sp <- as_Spatial(polygons_sf)
    polygons_sp <- spTransform(polygons_sp, proj)
    
    # create raster with resolution res.link.
    e <- extent(parcels)
    e@xmin <- floor(e@xmin / res.link) * res.link
    e@ymin <- floor(e@ymin / res.link) * res.link
    e@xmax <- ceiling(e@xmax / res.link) * res.link
    e@ymax <- ceiling(e@ymax / res.link) * res.link
    r <- raster(ext = e, resolution = res.link, crs = proj)
    values(r) <- NA
    
    # count number of particles in each cell,
    # find original raster cells
    tab <- cellFromXY(r, parcels)
    tab <- table(tab)
    r[as.numeric(names(tab))] <- tab
    
    # crop around point locations for faster extracting
    r <- crop(trim(r, padding = 1), e)
    
    #  convert to polygons for faster extracting
    r <- rasterToPolygons(r)
    polygon_parcels <- over(polygons_sp, r, fn = mean)
    polygon_parcels <- data.frame(polygon_parcels) %>% 
      rename(hyads = layer)
    polygon_parcels$id <- polygons_sf$id
    na.omit(polygon_parcels)
  }
  
  polygon_parcels <- full_join(get_polygon_counts(parcels, proj, polygons_sf), 
                               get_polygon_hyads(parcels, proj, polygons_sf, res.link))

  polygon_parcels$w <- X$w
  polygon_parcels$source <- X$ID
  polygon_parcels$start_day <- X$start_day
  polygon_parcels$start_hour <- X$start_hour
  polygon_parcels<- data.table(polygon_parcels, stringsAsFactors = FALSE)

  print(paste("linked output from", hysp_file))
  return(polygon_parcels)
}
