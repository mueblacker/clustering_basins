# Set working directory
setwd("/my/working/directory/data")

# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
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
#vset <- Sys.getenv(c("VSET"))


# Directories -------------------------------------------------------------

# Create paths for output

vset_path <- paste0("/my/working/directory/data/partitional_clustering/screening")
if(!dir.exists(vset_path)) dir.create(vset_path)

basin_path <- paste0(vset_path, "/basin_", cunit, "_", basinID)
if(!dir.exists(basin_path)) dir.create(basin_path)


# Input data --------------------------------------------------------------

basin <- fread(paste0("/my/working/directory/data/stream_characterization/basins/", 
                      "/basin_", cunit, "_", basinID,".csv"))


# Scale variables ---------------------------------------------------------

# Remove columns with IDs, river names, etc.
df <- basin[,4:ncol(basin)] %>%
	select(!stream_sinosoid) 
  # mutate(random = runif(nrow(basin), 1, 100))
  
# Scale dataset
df_sc <- df %>% scale() 


# Remove NA variables -----------------------------------------------------

# Check for values with NA
na_var <- as.data.table(df_sc) %>% 
  select_if(~sum(is.na(.)) > 0)

# Save variable names with NAs
na <- as.data.table(names(na_var)) %>% 
  rename(NA_variables = V1)


# Remove NA columns (e.g. land cover classes with 0% for all sub-basins) 
df_sc <- as.data.table(df_sc) %>% 
  select_if(~sum(!is.na(.)) > 0)

basin_sc <- basin[,1:3] %>% 
  bind_cols(df_sc)

# Save output -------------------------------------------------------------

fwrite(na, paste0(basin_path, "/NA_variables_", cunit, "_", 
                  basinID, ".csv"))
fwrite(basin_sc, paste0(basin_path, "/basin_envVar_sc_", cunit, "_", 
                        basinID,  ".csv"))

# Exit R ------------------------------------------------------------------

quit(save = "no")
