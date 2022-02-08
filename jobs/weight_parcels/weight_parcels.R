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
# load weight_parcels function

source("./R/weight_parcels_parallel.R")

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

hysp_dir = hysp_dir
mc.cores = parallel::detectCores()

for(c in 1:(length(chunk_seq) - 1)) {
  range = seq(chunk_seq[c]  + 1, chunk_seq[c+1])
  input.refs = data.table(input[range,], stringsAsFactors = FALSE)
  
  run_log <- try({
    weight_parcels_parallel(input.refs = input.refs, 
                            hysp_dir = hysp_dir, 
                            mc.cores = mc.cores)
  })
  
  run_log <- unlist(run_log)
  flag <- length(grep("Error", run_log))
  cat(paste0("weight_parcels_", 
             args$year, "_", 
             args$n, "_",
             c, " flag ",
             flag, "\n"), file = "flag.txt", append = TRUE)
}
