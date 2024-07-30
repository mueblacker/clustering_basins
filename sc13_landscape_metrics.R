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
usePackage("terra")
usePackage("landscapemetrics")


# Define computational unit
cu <- c(rep(c("102", "88", "59", "75", "20", "47"), 6))
# Define basin ID
id <-  c(rep(c("812813", "649217", "1173421", "560810", "1320241", "481455"), 6))

# Define the set of variables
set <- c(rep("bo", 18), rep("bg", 18)) 

rnum <- c(rep(256,6), rep(543, 6), rep(1234,6), rep(256,6), rep(543, 6),  rep(1234,6))
# Define nstart
nstart <- rep(500,36)

# Define UTM code
utm <- c(rep(c("EPSG:32750", "EPSG:24345", "EPSG:25832", "EPSG:21097", "EPSG:3740", "EPSG:31984"), 6))

bst_ncl <- fread("/my/working/directory/data/partitional_clustering/bst_ncl.txt", keepLeadingZeros =TRUE)

first <- TRUE
for(n in c(1:36)){
  
  cunit <- cu[n]
  basinID <- id[n]
  vset <- set[n]
  nr <- rnum[n]
  nst <- nstart[n]
  cs <- utm[n]
  
  ncl <- bst_ncl %>% 
    filter(CompUnit == cunit & BasinID == basinID & Set == vset & SEED == nr & NSTART == nst) %>% 
    .$NCL
  
  basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                       vset, "/basin_", cunit, "_", basinID)
  
  # Path to cluster raster file
  r_path <- paste0(basin_path, "/reclassify") 
  
  # Create paths for output
  lm_path <- paste0("/my/working/directory/data/partitional_clustering/")
  if(!dir.exists(lm_path)) dir.create(lm_path)  
  
# Input data --------------------------------------------------------------
  
  # Load raster file of the cluster solution
  basin <- rast(paste0(r_path, "/subc_reclass_", ncl, "k_", cunit, "_", basinID, 
                        "_", vset, "_seed", nr, "_nstart", nst, ".tif"))
  
  basin <- project(basin, cs , method = "near")
  
  # Calculate landscape metrics
  
  # At landscape level
  
  # Edge Density (Area and Edge metric)
  # Meter per hectare
  ed <- lsm_l_ed(basin)
  
  ed <- ed %>% 
    rename(ed = value) %>% 
    select(level, ed)
  
  # Patch density
  # Number per hectare
  pd <- lsm_l_pd(basin)
  
  pd <- pd %>% 
    rename(pd = value) %>% 
    select(level, pd)
  
  # Join metrics in one table
  all_l_metrics <- inner_join(ed, pd, by = "level")
  
  # Create table with basin information and add metrics table
  basin_l_metrics <- tibble(comp_unit = cunit,
                            basin_id = basinID,
                            design = vset,
                            seed = nr,
                            ok = ncl) %>% 
    bind_cols(all_l_metrics)
  
  if(first == TRUE){
    
    output_table <- basin_l_metrics
    fwrite(output_table, paste0(lm_path, "basin_landscape_metrics_epd_tmp.csv"))
    first <- FALSE
    
  }else{
    
    output_table <- output_table %>% 
      bind_rows(basin_l_metrics)
    fwrite(output_table, paste0(lm_path, "basin_landscape_metrics_epd_tmp.csv"))   
  }
}




for(n in c(1:18)){
  
  cunit <- cu[n]
  nr <- rnum[n]
  vset <- "gg"
  cs <- utm[n]
  
  ncl <- bst_ncl %>% 
    filter(CompUnit == "00" & BasinID == "000006" & Set == "gg" & SEED == nr & NSTART == 500) %>% 
    .$NCL
  
  basin_path <- paste0("/my/working/directory/data/partitional_clustering/gg/basin_00_000006")
  
  # Path to cluster raster file
  r_path <- paste0(basin_path, "/reclassify")  
  

  # Input data --------------------------------------------------------------
  
  # Load raster file of the cluster solution
  basin <- rast(paste0(r_path, "/subc_reclass_", ncl, "k_", cunit, "_000006_gg_seed", 
                       nr, "_nstart500.tif"))
  
  basin <- project(basin, cs , method = "near")
  
  # Calculate landscape metrics
  
  # At landscape level
  
  # Edge Density (Area and Edge metric)
  # Meter per hectare
  ed <- lsm_l_ed(basin)
  
  ed <- ed %>% 
    rename(ed = value) %>% 
    select(level, ed)
  
  # Patch density
  # Number per hectare
  pd <- lsm_l_pd(basin)
  
  pd <- pd %>% 
    rename(pd = value) %>% 
    select(level, pd)
  
  # Join metrics in one table
  all_l_metrics <- inner_join(ed, pd, by = "level")
  
  # Create table with basin information and add metrics table
  basin_l_metrics <- tibble(comp_unit = cunit,
                            basin_id = basinID,
                            design = vset,
                            seed = nr,
                            ok = ncl) %>% 
    bind_cols(all_l_metrics)
  

  output_table <- output_table %>% 
    bind_rows(basin_l_metrics)
  fwrite(output_table, paste0(lm_path, "basin_landscape_metrics_epd_tmp.csv"))   

}

# Calculate summary
sum_table <- output_table %>% 
  group_by(design, seed) %>%
  summarise(mean_ed = mean(ed),
            mean_pd = mean(pd))
  
 

# Write output files
fwrite(output_table, paste0(lm_path, "basin_landscape_metrics_epd.csv"))  
fwrite(sum_table, paste0(lm_path, "basin_landscape_metrics_epd_summary.csv"))  
  