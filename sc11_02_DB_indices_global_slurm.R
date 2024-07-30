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
usePackage("purrr")
usePackage("fpc")
usePackage("clusterCrit")
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

# Min. and max. number of cluster
min_k <- as.numeric(Sys.getenv(c("MINK")))
max_k <- as.numeric(Sys.getenv(c("MAXK")))


# Directories -------------------------------------------------------------

basin_path <- paste0("/my/working/directory/data/partitional_clustering/basins/", 
                     vset, "/basin_", cunit, "_", basinID)

k_path <- paste0(basin_path, "/kmeans")

# Create paths for indices output
idx_path <- paste0(basin_path, "/indices")
if(!dir.exists(idx_path)) dir.create(idx_path)


# Input data --------------------------------------------------------------

# Load scale df
basin <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", basinID, 
                      "_", vset, ".csv"))


# Load kmeans calculation
k <- read_rds(paste0(k_path, "/kmean_", min_k, "_", max_k, "_", cunit, "_",
                     basinID, "_", vset ,"_seed", rnum, "_nstart", nstr, ".rds"))


# Preparation of the dataset ----------------------------------------------

# Convert data table to matrix
df_sc <- as.matrix(basin[,4:ncol(basin)])

# Cluster indices calculation ---------------------------------------------

# Define numbers of k to test
if(min_k == 1){
  min_k <- 2
  centers <- min_k:max_k
}else{
  centers <- min_k:max_k
}

maxCl <- max(centers)-1

registerDoMC(20)

print("Start indices calculation")

t0 <- now()

idx <- foreach(i = centers, .packages = c("clusterCrit", "data.table", "tidyverse")) %dopar% {

    tmp <- intCriteria(df_sc, k[[paste0("n=",i)]]$cluster, c("Davies_Bouldin"))
 
    #additional indices:"GDI33","Silhouette","Calinski_Harabasz"
 
    as.data.table(tmp) %>%
    pivot_longer(., everything(), names_to = "indices", values_to = "values") %>% 
    mutate(k=i)
    
}

t1 <- finish_progress(maxCl, t0, "cluster centers")
print(t1)

# Save output -------------------------------------------------------------

write(x = t1, file = paste0(idx_path, "/time_idx.txt"), append = T)
write_rds(idx, paste0(idx_path, "/idx_", min_k,"_", max_k, "k_", cunit, "_", 
                      basinID, "_", vset, "_seed", rnum, "_nstart", nstr, ".rds"))


# Create tables -----------------------------------------------------------


# Total within sum of squares
wss <- map2_df(k, names(k), ~ tibble(indices = "tot.withinss", values = .x$tot.withinss, 
                                     k = str_remove(.y, "n=") %>% as.numeric(.)))

# Table with indices
idx_tbl <- bind_rows(idx) %>%
  bind_rows(wss)

# Normalization of the total within sum of squares
sse_dat <- map2_df(k, names(k), ~ tibble(k = str_remove(.y, "n=") %>% as.numeric(.), 
                                         norm_within_ssq  = .x$tot.withinss/.x$totss, ))


# Save tables -------------------------------------------------------------

fwrite(idx_tbl, paste0(idx_path, "/idx_table_", min_k,"_", max_k, "k_", 
                       cunit, "_", basinID , "_", vset,  "_seed", rnum, 
                       "_nstart", nstr, ".csv"))
fwrite(sse_dat, paste0(idx_path, "/norm_within_ssq_", min_k,"_", max_k, "k_",  
                       cunit, "_", basinID , "_", vset,  "_seed", rnum, 
                       "_nstart", nstr, ".csv"))

# Exit R ------------------------------------------------------------------

gc()
quit(save = "no")
