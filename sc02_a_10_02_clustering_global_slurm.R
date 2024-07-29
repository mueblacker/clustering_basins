# Set working directory
setwd("/my/working/directory/data")

# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}


# Process time function
finish_progress <- function(nmax, t0, word) {
  cat("\r", paste0(rep(" ", 75), collapse = ""))
  interval(t0,now()) %>%
    round(.) %>%
    as.period(.) %>%
    as.character(.) %>%
    paste("Completed",nmax, word, "in", .)
}

# Libraries ---------------------------------------------------------------
# Load libraries
usePackage("data.table")
usePackage("tidyverse")
usePackage("lubridate")
usePackage("doMC")
usePackage("foreach")


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
# Define number of clusters for kmeans
min_k <- as.numeric(Sys.getenv(c("MINK")))
max_k <- as.numeric(Sys.getenv(c("MAXK")))


# Directories -------------------------------------------------------------

basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                     vset, "/basin_", cunit, "_", basinID)
if(!dir.exists(basin_path)) dir.create(basin_path)

# Output path
k_path <- paste0(basin_path, "/kmeans")
if(!dir.exists(k_path)) dir.create(k_path)

# Input data --------------------------------------------------------------

basin <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", basinID, 
                       "_", vset, ".csv"))


# Preparation of the dataset ----------------------------------------------

# Convert data table to matrix
df_sc <- as.matrix(basin[,4:ncol(basin)])


# k-means cluster analysis ------------------------------------------------

# Define numbers of k to test
centers <- min_k:max_k

# Register cores
#registerDoMC(max(centers))
registerDoMC(20)

print("Start clusting")
t0 <- now()
# kmeans for different numbers of k
k <- foreach(i = centers) %dopar% {
    set.seed(rnum) 
    kmeans(df_sc, centers = i, nstart=nstr, iter.max = 500)

}

# Name the lists
names(k) <- paste0("n=", centers)

t1 <- finish_progress(max(centers), t0, "cluster centers")
print(t1)


# Save output -------------------------------------------------------------

write(x = t1, file = paste0(k_path, "/time_kmeans_60k.txt"), append = T)
write_rds(k, paste0(k_path, "/kmean_", min_k, "_", max_k, "_", cunit, "_", 
                    basinID, "_", vset, "_seed", rnum, "_nstart", nstr, ".rds"))


# Exit R ------------------------------------------------------------------

gc()
quit(save = "no")



