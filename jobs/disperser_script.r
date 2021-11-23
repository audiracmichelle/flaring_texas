# disperser script

library(disperseR)
library(USAboundaries)
library(USAboundariesData)
#library(tidycensus)
#### include your census api key
#census_api_key('<your_key>')

######## ######## ######## ########
# 
# set /home/kitematic as working directory in docker container
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
  filter(year == 2017, 
         #month %in% c(1,2,3)
         )

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
                    start.year = "2017",
                    start.month = "01",
                    end.year="2017",
                    end.month="12" # <- temporary filter
                    )
# to validate that this function ran properly, 
# files should be found inside the /main/input folder
# system("ls -R /home/rstudio/kitematic/tests/main/input/meteo")

######## ######## ######## ########
# run_disperser_parallel
######## ######## ######## ########

input.refs = data.table(input, stringsAsFactors = FALSE)
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

run_log <- unlist(hysp_raw)
length(grep("Error", run_log))
length(grep("/home/rstudio", run_log))
#write_rds(hysp_raw, "hysp_raw.rds")
#write_rds(run_log, "run_log.rds")

# Several warnings will pop, but this is expected (I looked into splitR's github issues)
# the output is a list that contains strings. The strings describe the location of the hysplit output

######## ######## ######## ########
# link_units
######## ######## ######## ########
lapply(disperseR::units, class)
lapply(input.refs, summary)

link.to = 'counties'
mc.cores = parallel::detectCores()
year.mons <- disperseR::get_yearmon(start.year = "2017",
                                    start.month = "01",
                                    end.year = "2017",
                                    end.month = "12")
pbl.height = NULL
pbl_trim = FALSE

counties. = USAboundaries::us_counties( ) %>%
  filter(statefp == "48")

# # python
# import wget
# from zipfile import ZipFile
# import os
# 
# url = 'https://www2.census.gov/geo/tiger/TIGER2016/TRACT/tl_2016_48_tract.zip'
# wget.download(url, os.path.expanduser('~/tmp'))
# file_name = os.path.expanduser('~/tmp/tl_2016_48_tract.zip')
# ZipFile(file_name, 'r').extractall(os.path.expanduser('~/tmp/tl_2016_48_tract/'))
# os.system("ls ~/tmp/tl_2016_48_tract/")

tracts_sf <- st_read("~/tmp/tl_2016_48_tract/tl_2016_48_tract.shp") 
tracts_sf %<>% 
  filter(STATEFP == "48") %>% 
  rename(statefp = STATEFP, 
         countyfp = COUNTYFP, 
         geoid = GEOID, 
         name = NAME) %>% 
  mutate(statefp = as.character(statefp), 
         countyfp = as.character(countyfp), 
         geoid = as.character(geoid), 
         state_name = statefp) 

class(counties.)
lapply(counties., class)
class(tracts_sf)
lapply(tracts_sf, class)

crosswalk. = NULL
duration.run.hours = 12
overwrite = FALSE

units.run <- input.refs %>%
  distinct(ID, uID, Latitude, Longitude, Height, year)
units.run <- data.table(units.run, stringsAsFactors = FALSE)

linked_counties <- disperseR::link_all_units(
  units.run = units.run,
  link.to = link.to,
  mc.cores = mc.cores,
  year.mons = year.mons,
  #pbl.height = pblheight,
  pbl_trim = pbl_trim,
  counties. = tracts_sf,
  crosswalk. = crosswalk.,
  duration.run.hours = duration.run.hours,
  overwrite = overwrite)

linked_counties %<>% 
  na.omit()

write_rds(linked_counties, "./data/linked_counties.rds")
