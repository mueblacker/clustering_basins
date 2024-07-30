# Set working directory
setwd("/my/working/directory/data")
# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}



# Libraries ---------------------------------------------------------------

usePackage("data.table")
usePackage("tidyverse")
usePackage("doMC")
usePackage("foreach")
usePackage("fpc")

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
# Define number of cluster
ncl <-  as.numeric(Sys.getenv(c("NCL")))
# Define number of boot samples
min_B <-  as.numeric(Sys.getenv(c("MINB")))
max_B <-  as.numeric(Sys.getenv(c("MAXB")))

# Directories -------------------------------------------------------------
# Define path
# Yale-Server
basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                     vset, "/basin_", cunit, "_", basinID)

k_path <- paste0(basin_path, "/kmeans")

stb_path <- paste0(basin_path, "/stability")
if(!dir.exists(stb_path)) dir.create(stb_path)

# Input data --------------------------------------------------------------
# Load scaled environmental variables
basin <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", basinID, 
                      "_", vset, ".csv"))


# Prepare data ------------------------------------------------------------

# Convert data table to matrix
data <- as.matrix(basin[,4:ncol(basin)])

# Cluster stability -------------------------------------------------------

n <- nrow(data)
boot <- min_B:max_B

registerDoMC(20)

bsamp <- foreach(i = 1:20) %dopar% {
  sample(n, n, replace = TRUE)
}

bc1 <- foreach(i = 1:20) %dopar% {

   mdata <- data[bsamp[[i]], ]
  
   set.seed(rnum)
   kmeans(mdata, centers = ncl, nstart=nstr, iter.max = 500)
    
}

# Name the lists
names(bc1) <- paste0("b=", boot)
names(bsamp) <- paste0("b=", boot)

# Save boot result --------------------------------------------------------

write_rds(bsamp, paste0(stb_path, "/boot_samples_", min_B, "_", max_B, "B_", cunit, "_", 
                      basinID, "_", vset ,"_seed", rnum, "_nstart",
                      nstr, ".rds"))

write_rds(bc1, paste0(stb_path, "/kmean_boot_", min_B, "_", max_B, "B_", cunit, "_", 
                          basinID, "_", vset ,"_seed", rnum, "_nstart",
                          nstr, ".rds"))

# Exit R ------------------------------------------------------------------

quit(save = "no")
