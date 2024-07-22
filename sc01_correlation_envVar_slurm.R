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
usePackage("corrr")
usePackage("lubridate")


# Select basin and dataset ------------------------------------------------

# Define computational unit
cunit <- Sys.getenv(c("CUNIT"))
# Define basin ID
basinID <- Sys.getenv(c("BID"))
# Define the set of variables
vset <- Sys.getenv(c("VSET"))


# Directories -------------------------------------------------------------

# Path to environmental variable dataset
basin_path <- paste0("/my/working/directory/data/partitional_clustering/",
                     vset, "/basin_", cunit, "_", basinID)

# Create paths for correlation output
corr_path <- paste0(basin_path, "/correlation")
if(!dir.exists(corr_path)) dir.create(corr_path)

# Input data --------------------------------------------------------------

basin_sc <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", 
                         basinID,".csv"))

# Correlation analysis ----------------------------------------------------

#t0 <- now()

#pear_corr_matrix <- correlate(basin_sc[,4:ncol(basin_sc)], 
#                         use = 'pairwise.complete.obs',
#                         method = "pearson",
#                         diagonal = NA) # %>% 
#                         rearrange()  # rearrange by correlations
              

#t1 <- interval(t0, now()) %>% 
#  as.period() %>% round()


#print(paste0("Pearson's correlation finished in ", t1 ))

#pear_corr_greater_07 <- pear_corr_matrix %>% 
#  mutate_if(is.numeric, funs(replace(., abs(.)<=0.7, NA)))

#t0 <- now()

sman_corr_matrix <- correlate(basin_sc[,4:ncol(basin_sc)], 
                              use = 'pairwise.complete.obs',
                              method = "spearman",
                              diagonal = NA) # %>% 
#                             rearrange()  # rearrange by correlations


t1 <- interval(t0, now()) %>% 
  as.period() %>% round()


print(paste0("Spearman rank correlation finished in ", t1 ))

sman_corr_greater_07 <- sman_corr_matrix %>% 
  mutate_if(is.numeric, funs(replace(., abs(.)<=0.7, NA)))



# Save output -------------------------------------------------------------

fwrite(pear_corr_matrix, paste0(corr_path, "/pearson_corr_", cunit, "_", basinID , "_", vset, ".csv"))
fwrite(pear_corr_greater_07, paste0(corr_path, "/pearson_greater_07_", cunit, "_", basinID , "_", vset, ".csv"))

fwrite(sman_corr_matrix, paste0(corr_path, "/spearman_corr_", cunit, "_", basinID , "_", vset, ".csv"))
fwrite(sman_corr_greater_07, paste0(corr_path, "/spearman_greater_07_", cunit, "_", basinID , "_", vset, ".csv"))

# Exit --------------------------------------------------------------------

quit(save = "no")
