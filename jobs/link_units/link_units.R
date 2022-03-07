library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-start", "--start", default=NULL,
                    help="Start month", type="integer")
parser$add_argument("-end", "--end", default=NULL,
                    help="End month", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2015)
# args$start = as.integer(7)
# args$end = as.integer(8)
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas/vanilla"

####
# override original disperseR functions
source("./lib/link_all_units_subfun.R")
source("./lib/link_all_units.R")

#### 
# create dirs

disperseR::create_dirs(args$wkdir)

#### 
# prepare input

input <- read_rds("./data/jobs_input/disperser_input.rds")

input %<>% 
  filter(year == args$year, 
         month >= args$start,
         month <= args$end)

######## ######## ######## ########
# link_units
######## ######## ######## ########

input.refs = data.table(input, stringsAsFactors = FALSE)
units.run <- input.refs %>%
  distinct(ID, uID, Latitude, Longitude, Height, year)
units.run <- data.table(units.run, stringsAsFactors = FALSE)
link.to = 'counties'
mc.cores = parallel::detectCores()
year.mons <- disperseR::get_yearmon(start.year = as.character(args$year),
                                    start.month = as.character(args$start),
                                    end.year = as.character(args$year),
                                    end.month = as.character(args$end))
by.time = "month"
pbl_trim = FALSE
tracts_sf <- st_read("./data/input/tl_2016_48_tract/tl_2016_48_tract.shp") 
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
crosswalk. = NULL
duration.run.hours = 12
res.link = 12000
overwrite = FALSE

linked_counties <- link_all_units(
  units.run = units.run,
  link.to = link.to,
  mc.cores = mc.cores,
  year.mons = year.mons,
  by.time = by.time, 
  pbl_trim = pbl_trim,
  counties. = tracts_sf,
  crosswalk. = crosswalk.,
  duration.run.hours = duration.run.hours,
  overwrite = overwrite)

linked_counties %<>% 
  na.omit()

write_rds(linked_counties, 
          paste0(args$wkdir, 
                 "/data/jobs_output/", 
                 "linked_counties_", 
                 args$year, "_", 
                 args$start, "_", 
                 args$end, ".rds"))
