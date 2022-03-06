library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-n", "--n_chunks", default=100,
                    help="Total number of chunks of runs", type="integer")
parser$add_argument("-c", "--chunk", default=1,
                    help="Chunk to be run", type="integer")
parser$add_argument("-s", "--subchunks", default=1,
                    help="Total number of subchunks", type="integer")
parser$add_argument("-w", "--wkdir", default="/work/08317/m1ch3ll3/stampede2/flaring_texas",
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2015)
# args$n_chunks = as.integer(100)
# args$chunk = 9
# args$subchunks = 10
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

####
# override original disperseR functions
source("./lib/run_disperser_parallel.R")

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
# download met files

disperseR::get_data(data = "metfiles",
                    start.year = as.character(args$year),
                    start.month = "01",
                    end.year=as.character(args$year),
                    end.month="12"
                    )

####
# define chunks and run_disperser_parallel inputs

start = 0
end = nrow(input)

if((end - start) < args$n_chunks){
  chunk_seq = seq(start,end)
} else {
  chunk_seq = round(seq(start,end,length.out=(args$n_chunks + 1)))
}

chunk_seq = c(chunk_seq[args$chunk], chunk_seq[args$chunk+1])  

if(args$subchunks > 1) {
  if((chunk_seq[2] - chunk_seq[1]) < args$subchunks) {
    chunk_seq = seq(chunk_seq[1], chunk_seq[2])
  } else {
    chunk_seq = round(seq(chunk_seq[1],
                          chunk_seq[2],
                          length.out=(args$subchunks + 1)))
  }
}

pbl.height = NULL #pblheight
species = 'so2'
proc_dir = proc_dir
overwrite = FALSE
npart = 100
keep.hysplit.files = FALSE ## FALSE BY DEFAULT
mc.cores = parallel::detectCores()
for(c in 1:(length(chunk_seq) - 1)) {
  range = seq(chunk_seq[c]  + 1, chunk_seq[c+1])
  input.refs = data.table(input[range,], stringsAsFactors = FALSE)
  
  hysp_raw <- try({
    run_disperser_parallel(input.refs = input.refs,
                           pbl.height = pbl.height,
                           species = species,
                           proc_dir = proc_dir,
                           overwrite = overwrite,
                           npart = npart,
                           keep.hysplit.files = keep.hysplit.files,
                           mc.cores = mc.cores)
  })
  
  run_log <- unlist(hysp_raw)
  flag <- length(grep("Error", run_log))
  cat(paste0("Flag_", 
             args$year, "_", 
             args$n, "_",
             sprintf("%03d", args$chunk), "_",
             args$subchunks, "_", 
             sprintf("%02d", c), "_",
             flag, "\n"), file = "flag.txt", append = TRUE)
}
