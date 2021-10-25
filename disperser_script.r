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

impact_table_county_single <- disperseR::create_impact_table_single(
  data.linked=linked_counties,
  link.to = 'counties',
  data.units = units.run,
  counties. = USAboundaries::us_counties( ) %>%
    filter(statefp == "48"),
  map.unitID = "48013960100",
  map.month = "20161",
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


