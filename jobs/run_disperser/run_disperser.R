library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-start", "--start", default=NULL,
                    help="Chunk startpoint", type="integer")
parser$add_argument("-end", "--end", default=NULL,
                    help="Chunk endpoint", type="integer")
parser$add_argument("-n", "--n_chunks", default=20,
                    help="Total number of chunks of runs", type="integer")
parser$add_argument("-c", "--chunk", default=NULL,
                    help="Chunk to be run", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2016)
# args$start = NULL
# args$end = NULL
# args$n_chunks = as.integer(20)
# args$chunk = NULL
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

####
# override original disperseR functions
source("./R/run_disperser_parallel.R")

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
  filter(year == args$year, 
         #month %in% c(1,2,3)
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
                    end.month="12" # <- temporary filter
                    )

####
# define chunks and run_disperser_parallel inputs

if(is.null(args$start)){start = 0} else {start = args$start}
if(is.null(args$end)){end = nrow(input)} else {end = args$end}
chunk_seq = round(seq(start,end,length.out=(args$n_chunks + 1)))

if(!is.null(args$chunk)) {
  chunk_seq = c(chunk_seq[args$chunk], chunk_seq[args$chunk+1])  
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
             args$start, "_", 
             args$end, "_", 
             args$n, "_",
             c, "_",
             flag, "\n"), file = "flag.txt", append = TRUE)
}

