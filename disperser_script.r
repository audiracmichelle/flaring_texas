

```{r}
input %<>% 
  mutate(ID = GEOID, 
         uID = GEOID, 
         Height = 20, 
         year = year(date), 
         start_date = date, 
         duration_emiss_hours = 1,
         duration_run_hours = 24)

input_refs <- data.table(
  expand.grid(
    ID = "1",
    uID = "1",
    Latitude = 28.8857,
    Longitude = -98.1537,
    Height = 20,
    year = unique(2014),
    start_hour = c(0, 6, 12, 18),
    start_day = seq.Date(
      from = as.Date('2014-01-01'),
      to =   as.Date('2014-01-02'),
      by = '1 day'
    ),
    duration_emiss_hours = 1,
    duration_run_hours = 24#240
  )
)
```





source("./mini_disperseR.R")




# it looks like the disperser functions work better if a
# an existing address is given to `create_dirs`
# in this case use the location '/home/rstudio' to work
# with the docker container's file system
disperseR::create_dirs("/home/rstudio/kitematic/tests")

# disperseR::get_data(data = "all",
#                     start.year = "2016",
#                     start.month = "01",
#                     end.year = "2016",
#                     end.month = "12")
# the extraction prompts an error message.
disperseR::get_data(data = "metfiles",
                    start.year = "2016",
                    start.month = "01",
                    end.year="2016",
                    end.month="12")
# to validate that this function ran properly, the following
# files should be found inside the /main/input folder
# system("ls -R /home/rstudio/kitematic/tests/main/input/meteo")

input.refs <- data.table(
  expand.grid(
    ID = "1",
    uID = "1",
    Latitude = 28.8857,
    Longitude = -98.1537,
    Height = 20,
    year = unique(2014),
    start_hour = c(0, 6, 12, 18),
    start_day = seq.Date(
      from = as.Date('2014-01-01'),
      to =   as.Date('2014-01-02'),
      by = '1 day'
    ),
    duration_emiss_hours = 1,
    duration_run_hours = 12#240
  )
)


# I set the keep.hysplit.files = TRUE
# after running the following command you can look inside proc_dir
# and you will see the PARDUMP file and other files
# which are used by the NOOA executable to produce the hysplit output

# hysp_raw <- disperseR::run_disperser_parallel(input.refs = input.refs, #input_refs_subset,
#                                               pbl.height = NULL, #pblheight,
#                                               species = 'so2',
#                                               proc_dir = proc_dir,
#                                               overwrite = TRUE, ## FALSE BY DEFAULT
#                                               npart = 100, ##100 DEFAULT
#                                               keep.hysplit.files = TRUE, ## FALSE BY DEFAULT
#                                               mc.cores = parallel::detectCores())

hysp_raw <- run_disperser_parallel(input.refs = input.refs, #input_refs_subset,
                                              pbl.height = NULL, #pblheight,
                                              species = 'so2',
                                              proc_dir = proc_dir,
                                              overwrite = TRUE, ## FALSE BY DEFAULT
                                              npart = 100, ##100 DEFAULT
                                              keep.hysplit.files = TRUE, ## FALSE BY DEFAULT
                                              mc.cores = parallel::detectCores())

# Several warnings will pop, but this is expected (I looked into splitR's github issues)
# the output is a list that contains strings. The strings describe the location of the hysplit output

yearmons <- disperseR::get_yearmon(start.year = "2014",
                                   start.month = "01",
                                   end.year = "2014",
                                   end.month = "03")

unit <- input.refs %>%
  distinct(ID, uID, Latitude, Longitude, Height, year)
#unit$uID = 1
#unitID <- unit$ID

d <- list()
for(x in yearmons) {
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

counties = USAboundaries::us_counties() %>%
  filter(statefp == "48")
counties.sp <- sf::as_Spatial(counties)
counties.sp <- spTransform(counties.sp, p4s)

##########################

units.run <- input.refs
# link all units to counties
linked_counties <- disperseR::link_all_units(
  units.run=units.run,
  link.to = 'counties',
  mc.cores = parallel::detectCores(),
  year.mons = yearmons,
  #pbl.height = pblheight,
  pbl_trim = FALSE,
  counties. = USAboundaries::us_counties( ) %>%
    filter(statefp == "48"),
  crosswalk. = NULL,
  duration.run.hours = 12,
  overwrite = T)

head(linked_counties)
head(linked_grids)

unique(linked_zips$comb)

impact_table_zip_single <- disperseR::create_impact_table_single(
  data.linked=linked_zips,
  link.to = 'zips',
  data.units = unitsrun,
  zcta.dataset = zcta_dataset,
  map.unitID = "3136-1",
  map.month = "200511",
  metric = 'N')
impact_table_county_single <- disperseR::create_impact_table_single(
  data.linked=linked_counties,
  link.to = 'counties',
  data.units = unitsrun,
  counties. = USAboundaries::us_counties( ),
  map.unitID = "3136-1",
  map.month = "200511",
  metric = 'N')
impact_table_grid_single <- disperseR::create_impact_table_single(
  data.linked=linked_grids,
  link.to = 'grids',
  data.units = unitsrun,
  map.unitID = "3136-1",
  map.month = "200511",
  metric = 'N')

head(impact_table_zip_single)

link_plot_zips <- disperseR::plot_impact_single(
  data.linked = linked_zips,
  link.to = 'zips',
  map.unitID = "3136-1",
  map.month = "20061",
  data.units = unitsrun,
  zcta.dataset = zcta_dataset,
  metric = 'N',
  graph.dir = graph_dir,
  zoom = T, # TRUE by default
  legend.name = 'HyADS raw exposure',
  # other parameters passed to ggplot2::theme()
  axis.text = element_blank(),
  legend.position = c( .75, .15))
link_plot_grids <- disperseR::plot_impact_single(
  data.linked = linked_grids,
  link.to = 'grids',
  map.unitID = "3136-1",
  map.month = "20061",
  data.units = unitsrun,
  metric = 'N',
  graph.dir = graph_dir,
  zoom = F, # TRUE by default
  legend.name = 'HyADS raw exposure',
  # other parameters passed to ggplot2::theme()
  axis.text = element_blank(),
  legend.position = c( .75, .15))
link_plot_counties <- disperseR::plot_impact_single(
  data.linked = linked_counties,
  link.to = 'counties',
  map.unitID = "3136-1",
  map.month = "20061",
  counties. = USAboundaries::us_counties( ),
  data.units = unitsrun,
  metric = 'N',
  graph.dir = graph_dir,
  zoom = T, # TRUE by default
  legend.name = 'HyADS raw exposure',
  # other parameters passed to ggplot2::theme()
  axis.text = element_blank(),
  legend.position = c( .75, .15))

# the plots take some time to appear in the lower-right window but
# you should be able to see them
link_plot_zips
link_plot_grids
link_plot_counties


