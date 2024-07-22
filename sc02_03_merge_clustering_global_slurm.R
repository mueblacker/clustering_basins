# Set working directory
setwd("/my/working/directory/data")


# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}

# Function to combine nested lists
combine = function(...) {
  
  stack = rev(list(...))
  names(stack) = rep('', length(stack))
  result = list()
  
  while (length(stack)) {
    # pop a value from the stack
    obj = stack[[1]]
    root = names(stack)[[1]]
    stack = stack[-1]
    
    if (is.list(obj) && !is.null(names(obj))) {
      if (any(names(obj) == '')) {
        stop("Mixed named and unnamed elements are not supported.")
      }
      
      # restack for next-level processing
      if (root != '') {
        names(obj) = paste(root, names(obj), sep='|')
      }
      stack = append(obj, stack)
    } else {
      # clear a path to store result
      path = unlist(strsplit(root, '|', fixed=TRUE))
      for (j in seq_along(path)) {
        sub_path = path[1:j]
        if (is.null(result[[sub_path]])) {
          result[[sub_path]] = list()
        }
      }
      result[[path]] = obj
    }
  }
  
  return(result)
}


# Libraries ---------------------------------------------------------------

# Load libraries
usePackage("data.table")
usePackage("tidyverse")


# Select basin and dataset ------------------------------------------------

# Define computational unit
cunit <- Sys.getenv(c("CUNIT"))
# Define basin ID
basinID <- Sys.getenv(c("BID"))
# Define the set of variables
vset <- Sys.getenv(c("VSET"))
# Define seed
rnum <-  as.numeric(Sys.getenv(c("SEED")))
# Define number of starts
nstr <-  as.numeric(Sys.getenv(c("NSTART")))


# Directories -------------------------------------------------------------

basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                     vset, "/basin_", cunit, "_", basinID)

k_path <- paste0(basin_path, "/kmeans")

# Create paths for indices output
idx_path <- paste0(basin_path, "/indices")
if(!dir.exists(idx_path)) dir.create(idx_path)


# Input data --------------------------------------------------------------

# Load kmeans calculation
k1 <- read_rds(paste0(k_path, "/kmean_1_20_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))
k2 <- read_rds(paste0(k_path, "/kmean_21_40_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))
k3 <- read_rds(paste0(k_path, "/kmean_41_60_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))
k4 <- read_rds(paste0(k_path, "/kmean_61_80_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))
k5 <- read_rds(paste0(k_path, "/kmean_81_100_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))
k6 <- read_rds(paste0(k_path, "/kmean_101_120_", cunit, "_", basinID, "_", vset,
                      "_seed", rnum, "_nstart", nstr, ".rds"))

# Combine files -----------------------------------------------------------

k_comb <- combine(k6, k5, k4, k3, k2, k1)

# Save table -------------------------------------------------------------

write_rds(k_comb, paste0(k_path, "/kmean_120k_", cunit, "_", basinID, "_",  vset,
                         "_seed", rnum, "_nstart", nstr, ".rds"))
# Exit R ------------------------------------------------------------------

quit(save = "no")
