library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-n", "--n_chunks", default=200,
                    help="Total number of chunks of runs", type="integer")
parser$add_argument("-n", "--chunk", default=NULL,
                    help="Chunk to be run", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="integer")
args = parser$parse_args()

args=list()
args$y = as.integer(2015)
args$n_chunks = as.integer(200)
args$chunk = as.integer(3)
args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

#### 
# prepare input

input <- read_rds("./data/input/input.rds")

input %<>% 
  mutate(ID = GEOID, 
         uID = GEOID, 
         Height = 20, 
         year = year(date), 
         month = month(date),
         start_day = date, 
         duration_emiss_hours = 1,
         duration_run_hours = 12)

input %<>% 
  filter(year == as.numeric(args$y), 
         #month %in% c(1,2,3)
         )

#### 
# create dirs

disperseR::create_dirs("/work/08317/m1ch3ll3/stampede2/flaring_texas")

#### 
# download met files

disperseR::get_data(data = "metfiles",
                    start.year = as.character(args$year),
                    start.month = "01",
                    end.year=as.character(args$year),
                    end.month="12" # <- temporary filter
                    )

####
# define chunks and run_disperser_parallel inputs

N = nrow(input)
chunk_seq = round(seq(0,N,length.out=(args$chunk_n + 1)))

if(!is.null(args$chunk)) {
  chunk_seq = c(chunk_seq[args$chunk] + 1, chunk_seq[args$chunk+1])  
}

pbl.height = NULL #pblheight
species = 'so2'
proc_dir = proc_dir
overwrite = FALSE
npart = 100
keep.hysplit.files = FALSE ## FALSE BY DEFAULT
mc.cores = parallel::detectCores()

for(c in (length(chunk_seq) - 1)) {
  range = seq(chunk_seq[c] + 1, chunk_seq[c+1])
  input.refs = data.table(input[range], stringsAsFactors = FALSE)
  
  hysp_raw <- disperseR::run_disperser_parallel(input.refs = input.refs,
                                                pbl.height = pbl.height,
                                                species = species,
                                                proc_dir = proc_dir,
                                                overwrite = overwrite,
                                                npart = npart,
                                                keep.hysplit.files = keep.hysplit.files,
                                                mc.cores = parallel::detectCores())
}

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
