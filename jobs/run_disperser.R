library(disperseR)
library(argparse)

parser <- ArgumentParser()
parser$add_argument("-y", "--year", default=2015,
                    help="Year to run", type="integer")
parser$add_argument("-n", "--n_chunks", default=200,
                    help="Total number of chunks of runs", type="integer")
parser$add_argument("-c", "--chunk", default=NULL,
                    help="Chunk to be run", type="integer")
parser$add_argument("-w", "--wkdir", default=NULL,
                    help="Working directory", type="character")
args = parser$parse_args()

# args=list()
# args$year = as.integer(2016)
# args$n_chunks = as.integer(1000)
# args$chunk = as.integer(500)
# args$wkdir = "/work/08317/m1ch3ll3/stampede2/flaring_texas"

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

N = nrow(input)
chunk_seq = round(seq(0,N,length.out=(args$n_chunks + 1)))

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

for(c in 1:(length(chunk_seq) - 1)) {
  range = seq(chunk_seq[c] + 1, chunk_seq[c+1])
  input.refs = data.table(input[range,], stringsAsFactors = FALSE)
  
  flag = 1
  iter = 0
  while(flag > 0 | iter < 10) {
    hysp_raw <- disperseR::run_disperser_parallel(input.refs = input.refs,
                                                  pbl.height = pbl.height,
                                                  species = species,
                                                  proc_dir = proc_dir,
                                                  overwrite = overwrite,
                                                  npart = npart,
                                                  keep.hysplit.files = keep.hysplit.files,
                                                  mc.cores = parallel::detectCores())
    
    run_log <- unlist(hysp_raw)
    flag <- length(grep("Error", run_log))
    iter = iter + 1
  }
}
