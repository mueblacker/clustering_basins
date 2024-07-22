# Set working directory
setwd("/my/working/directory/data")


# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}


# Function to calculate the 90° distance from the chord line to the curve 
max_dist <- function(coord_i, chord) {
  alpha_0 <- atan(abs(diff(chord[,2]))/abs(diff(chord[,1])))
  c <- sqrt((coord_i[1] - chord[1,1])^2 + (coord_i[2] - chord[1,2])^2)
  alpha <- acos(abs(coord_i[1] - chord[1,1])/c) - alpha_0
  unname(sin(alpha)*c)
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
k <- read_rds(paste0(k_path, "/kmean_120k_", cunit, "_", basinID, "_", vset,
                     "_seed", rnum, "_nstart", nstr, ".rds"))


# Create tables -----------------------------------------------------------


# Total within sum of squares
wss <- map2_df(k, names(k), ~ tibble(indices = "tot.withinss", values = .x$tot.withinss, 
                                     k = str_remove(.y, "n=") %>% as.numeric(.)))


# Normalization of the total within sum of squares
sse_dat <- map2_df(k, names(k), ~ tibble(k = str_remove(.y, "n=") %>% as.numeric(.), 
                                         norm_within_ssq  = .x$tot.withinss/.x$totss, ))


# Save tables -------------------------------------------------------------

fwrite(wss, paste0(idx_path, "/wss_table_120k_", cunit, "_", basinID , "_", vset,
                   "_seed", rnum, "_nstart", nstr, ".csv"))
fwrite(sse_dat, paste0(idx_path, "/norm_within_ssq_120k_", cunit, "_", basinID , "_", vset,
                       "_seed", rnum, "_nstart", nstr, ".csv"))



# Determine chord line and distance between chord line and SSW curve ------

# Get min. and max. number of cluster k
chord <- filter(sse_dat, k == min(k) | k == max(k)) %>%
  arrange(k) %>%
  as.matrix()

# Calculate distance to the curve using the function max_dist
sse_dat$max_diff <- apply(sse_dat, 1, max_dist, chord)


# Select k where the distance is the longest
k_max <- sse_dat$k[which(sse_dat$max_diff == max(sse_dat$max_diff, na.rm = T))]


# Settings for vimp calculation

ncl_for_vimp <- data.table(CompUnit = cunit,
                   BasinID = basinID,
                   Set = vset,
                   Seed = rnum,
                   NStart = nstr,
                   NCL = k_max)

# Save table -------------------------------------------------------------
path <- "/my/working/directory/data/partitional_clustering"

if(!file.exists(paste0(path,  "/bst_ncl_screening.txt"))){
  write.table(x = ncl_for_vimp, file = paste0(path, "/bst_ncl_screening.txt"), append = T,
              col.names = TRUE, row.names = FALSE, quote = FALSE)
}else{
  write.table(x = ncl_for_vimp, file = paste0(path, "/bst_ncl_screening.txt"), append = T,
              col.names = FALSE, row.names = FALSE, quote = FALSE)
}

# Exit R ------------------------------------------------------------------

gc()
quit(save = "no")
