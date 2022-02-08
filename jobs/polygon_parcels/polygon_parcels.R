library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-n", "--n_chunks", default=20,
                    help="Total number of chunks of runs", type="integer")
parser$add_argument("-c", "--chunk", default=NULL,
                    help="Chunk to be run", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2016)
# args$n_chunks = as.integer(100)
# args$chunk = NULL
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

####
# load polygon_parcels_parallel function

source("./R/polygon_parcels_parallel.R")

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
  filter(year == args$year)

#### 
# create dirs

disperseR::create_dirs(args$wkdir)

####
# define chunks and weight_parcels_parallel inputs

if(nrow(input) < args$n_chunks){
  chunk_seq = seq(0,nrow(input))
} else {
  chunk_seq = round(seq(0,nrow(input),length.out=(args$n_chunks + 1)))
}

if(!is.null(args$chunk)) {
  chunk_seq = c(chunk_seq[args$chunk], chunk_seq[args$chunk+1])  
}

sf <- st_read("./data/input/tl_2016_48_tract/tl_2016_48_tract.shp") 
sf %<>% 
  filter(STATEFP == "48")  %>% 
  select(GEOID) %>% 
  mutate(GEOID = as.character(GEOID)) %>% 
  rename(id = GEOID)
hysp_dir = hysp_dir
mc.cores = parallel::detectCores()

for(c in 1:(length(chunk_seq) - 1)) {
  range = seq(chunk_seq[c]  + 1, chunk_seq[c+1])
  input.refs = data.table(input[range,], stringsAsFactors = FALSE)
  
  polygon_parcels_ <- try({
    polygon_parcels_parallel(input.refs = input.refs, 
                             sf = sf, 
                             hysp_dir = hysp_dir, 
                             mc.cores = mc.cores)
  })
  
  output_file <- file.path(ziplink_dir, 
                           paste0("polygon_parcels_", 
                                  args$year, "_", 
                                  args$n, "_",
                                  args$c, "_",
                                  c, ".fst"))
  
  write.fst(polygon_parcels_, output_file)

  cat(paste0("polygon_parcels_", 
             args$year, "_", 
             args$n, "_",
             args$c, "_",
             c, "\n"), file = "flag.txt", append = TRUE)
}
