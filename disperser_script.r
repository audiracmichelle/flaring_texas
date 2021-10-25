# disperser script

library(disperseR)
library(USAboundaries)
library(USAboundariesData)

######## ######## ######## ########
# data
#
# set /home/kitematic as working directory
#
######## ######## ######## ########

input <- read_rds("./data/input.rds")

#in case there are duplicated entries of input, use them to weight them more

input %<>% 
  mutate(ID = GEOID, 
         uID = GEOID, 
         Height = 20, 
         year = year(date), 
         month = month(date),
         start_day = date, 
         duration_emiss_hours = 1,
         duration_run_hours = 12)

input %<>% # <- temporary filter
  filter(year == 2016, 
         month %in% c(1,2,3))

# it looks like the disperser functions work better if
# an existing address is given to `create_dirs`
# in this case use the location '/home/rstudio' to work
# with the docker container's file system
disperseR::create_dirs("/home/rstudio/kitematic/")

# disperseR::get_data(data = "all",
#                     start.year = "2016",
#                     start.month = "01",
#                     end.year = "2016",
#                     end.month = "12")
# the extraction of data = "all" prompts an error message.
disperseR::get_data(data = "metfiles",
                    start.year = "2016",
                    start.month = "01",
                    end.year="2016",
                    end.month="3" # <- temporary filter
                    )
# to validate that this function ran properly, 
# files should be found inside the /main/input folder
# system("ls -R /home/rstudio/kitematic/tests/main/input/meteo")

######## ######## ######## ########
# run_disperser_parallel
######## ######## ######## ########

input.refs = data.table(input, ststringsAsFactors = FALSE)
pbl.height = NULL #pblheight
species = 'so2'
proc_dir = proc_dir
overwrite = FALSE
npart = 100
keep.hysplit.files = FALSE ## FALSE BY DEFAULT
mc.cores = parallel::detectCores()

hysp_raw <- disperseR::run_disperser_parallel(input.refs = input.refs,
                                              pbl.height = pbl.height,
                                              species = species,
                                              proc_dir = proc_dir,
                                              overwrite = overwrite,
                                              npart = npart,
                                              keep.hysplit.files = keep.hysplit.files,
                                              mc.cores = parallel::detectCores())

run_disperser_parallel_log <- unlist(hysp_raw)
length(grep("Error", run_disperser_parallel_log))
length(grep("/home/rstudio", run_disperser_parallel_log))

# Several warnings will pop, but this is expected (I looked into splitR's github issues)
# the output is a list that contains strings. The strings describe the location of the hysplit output

######## ######## ######## ########
# test link_units
######## ######## ######## ########
lapply(disperseR::units, summary)
lapply(input.refs, summary)

units.run <- input.refs %>%
  distinct(ID, uID, Latitude, Longitude, Height, year)
link.to = 'counties'
mc.cores = parallel::detectCores()
year.mons <- disperseR::get_yearmon(start.year = "2016",
                                    start.month = "01",
                                    end.year = "2016",
                                    end.month = "03")
pbl.height = NULL
pbl_trim = FALSE
counties. = USAboundaries::us_counties( ) %>%
  filter(statefp == "48")
crosswalk. = NULL
duration.run.hours = 12
overwrite = FALSE

# link all units to counties
linked_counties <- disperseR::link_all_units(
  units.run = units.run,
  link.to = link.to,
  mc.cores = 1,
  year.mons = year.mons,
  #pbl.height = pblheight,
  pbl_trim = pbl_trim,
  counties. = counties.,
  crosswalk. = crosswalk.,
  duration.run.hours = duration.run.hours,
  overwrite = overwrite)

write_rds(linked_counties, "linked_counties.rds")

#### ####

d <- list()
for(x in year.mons) {
  print(x)
  month_YYYYMM = x
  #month_YYYYMM = yearmons[1]
  duration.run.hours = 12
  
  start.date <-
    as.Date(paste(
      substr(month_YYYYMM, 1, 4),
      substr(month_YYYYMM, 5, 6),
      '01',
      sep = '-'
    ))
  end.date <-
    seq(start.date, by = paste (1, "months"), length = 2)[2] - 1
  
  ## name the eventual output file
  #output_file <-
  #  file.path( ziplink_dir,
  #             paste0("countylinks_", unit$ID, "_", start.date, "_", end.date, ".fst"))
  
  ## identify dates for hyspdisp averages and dates for files to read in
  vec_dates <-
    as(
      seq.Date(
        as.Date(start.date),
        as.Date(end.date),
        by = '1 day'),
      'character')
  vec_filedates <-
    seq.Date(
      from = as.Date( start.date) - ceiling( duration.run.hours / 24), # <----- validate
      to = as.Date( end.date),
      by = '1 day'
    )
  
  ## list the files
  pattern.file <-
    paste0( '_',
            gsub( '[*]', '[*]', unit$ID),
            '_(',
            paste(vec_filedates, collapse = '|'),
            ').*\\.fst$'
    )
  hysp_dir.path <-
    file.path( hysp_dir,
               unique( paste( year( vec_filedates),
                              formatC( month( vec_filedates), width = 2, flag = '0'),
                              sep = '/')))
  files.read <-
    list.files( path = hysp_dir.path,
                pattern = pattern.file,
                recursive = F,
                full.names = T)
  
  ## read in the files
  d_ <- lapply(files.read, read.fst, as.data.table = TRUE)
  
  # if( length( d) == 0)
  #   return( paste( "No files available to link in", month_YYYYMM))
  # print(  paste( Sys.time(), "Files read and combined"))
  
  ## Combine all parcels into single data table
  d_ <- rbindlist(d_)
  
  d[[x]] <- na.omit(d_)
}

d <- bind_rows(d)

p4s <- "+proj=aea +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m"
d <- spTransform(
  SpatialPointsDataFrame(coords = d[, .(lon, lat)],
                         data = d,
                         proj4string = CRS( "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")),
  p4s
)

write_rds(d, "particles.rds")

