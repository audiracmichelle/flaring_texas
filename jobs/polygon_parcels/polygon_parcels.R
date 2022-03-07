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
# args$year = as.integer(2015)
# args$n_chunks = as.integer(100)
# args$chunk = 1
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

####
# load polygon_parcels_parallel function

source("./R/polygon_parcels_parallel.R")

#### 
# prepare input

input <- read_rds("./data/jobs_input/disperser_input.rds") 

input %<>% 
  filter(year == args$year
  )

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
  
  polygon_parcels <- try({
    polygon_parcels_parallel(input.refs = input.refs, 
                             sf = sf, 
                             hysp_dir = hysp_dir, 
                             mc.cores = mc.cores)
  })
  
  # polygon_parcels %>% 
  #   group_by(source, start_day, start_hour) %>% 
  #   summarise(parcels = sum(count)) %>% 
  #   pull(parcels)
  
  if(!dir.exists(file.path(ziplink_dir, args$year)))
    dir.create(file.path(ziplink_dir, args$year))
  output_file <- file.path(ziplink_dir, 
                           args$year, 
                           paste0("polygon_parcels_", 
                                  args$year, "_", 
                                  args$n, "_",
                                  args$c, "_",
                                  c, ".fst"))
  
  write.fst(polygon_parcels, output_file)

  # cat(paste0("polygon_parcels_", 
  #            args$year, "_", 
  #            args$n, "_",
  #            args$c, "_",
  #            c, "\n"), file = "flag.txt", append = TRUE)
}

files <- file.path(file.path(ziplink_dir, args$year), 
                   list.files(file.path(ziplink_dir, args$year)))
polygon_parcels <- lapply(files, function(x) read.fst(x))
polygon_parcels <- rbindlist(polygon_parcels)
write_rds(polygon_parcels, 
          file.path(args$wkdir, 
                    "./data/output/",  
                    paste0("polygon_parcels_", 
                           args$year, ".rds"))
          )
