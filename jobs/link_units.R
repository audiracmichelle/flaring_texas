library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2015)
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

######## ######## ######## ########
# link_units
######## ######## ######## ########

units.run <- input.refs %>%
  distinct(ID, uID, Latitude, Longitude, Height, year)
units.run <- data.table(units.run, stringsAsFactors = FALSE)
link.to = 'counties'
mc.cores = parallel::detectCores()
year.mons <- disperseR::get_yearmon(start.year = as.character(args$year),
                                    start.month = "01",
                                    end.year = as.character(args$year),
                                    end.month = "12")
#pbl.height = NULL
pbl_trim = FALSE
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
crosswalk. = NULL
duration.run.hours = 12
overwrite = FALSE

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

write_rds(linked_counties, 
          paste(args$wkdir, 
                "/data/output/", 
                "linked_counties_", 
                args$year,
                ".rds"))
