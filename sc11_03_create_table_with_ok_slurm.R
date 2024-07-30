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
usePackage("stringr")

# Directories -------------------------------------------------------------
bo <- "/my/working/directory/partitional_clustering/bo/"
bg <- "/my/working/directory/data/partitional_clustering/bg/"
gg <- "/my/working/directory/partitional_clustering/gg/"

basin102 <-"basin_102_812813/indices/"
basin88 <- "basin_88_649217/indices/"
basin59 <- "basin_59_1173421/indices/"
basin75 <- "basin_75_560810/indices/"
basin20 <- "basin_20_1320241/indices/"
basin47 <- "basin_47_481455/indices/"
basin06 <- "basin_00_000006/indices/"


files  <- c(# Basin 102_812813
            paste0(bo, basin102, "idx_table_60k_102_812813_bo_seed256_nstart500.csv"),
            paste0(bo, basin102, "idx_table_60k_102_812813_bo_seed543_nstart500.csv"),
            paste0(bo, basin102, "idx_table_60k_102_812813_bo_seed1234_nstart500.csv"),
            paste0(bg, basin102, "idx_table_60k_102_812813_bg_seed256_nstart500.csv"),
            paste0(bg, basin102, "idx_table_60k_102_812813_bg_seed543_nstart500.csv"),
            paste0(bg, basin102, "idx_table_60k_102_812813_bg_seed1234_nstart500.csv"),

            # Basin 88_649217
            paste0(bo, basin88, "idx_table_60k_88_649217_bo_seed256_nstart500.csv"),
            paste0(bo, basin88, "idx_table_60k_88_649217_bo_seed543_nstart500.csv"),
            paste0(bo, basin88, "idx_table_60k_88_649217_bo_seed1234_nstart500.csv"),
            paste0(bg, basin88, "idx_table_60k_88_649217_bg_seed256_nstart500.csv"),
            paste0(bg, basin88, "idx_table_60k_88_649217_bg_seed543_nstart500.csv"),
            paste0(bg, basin88, "idx_table_60k_88_649217_bg_seed1234_nstart500.csv"),
            
            # Basin 59_1173421
            paste0(bo, basin59, "idx_table_60k_59_1173421_bo_seed256_nstart500.csv"),
            paste0(bo, basin59, "idx_table_60k_59_1173421_bo_seed543_nstart500.csv"),
            paste0(bo, basin59, "idx_table_60k_59_1173421_bo_seed1234_nstart500.csv"),
            paste0(bg, basin59, "idx_table_60k_59_1173421_bg_seed256_nstart500.csv"),
            paste0(bg, basin59, "idx_table_60k_59_1173421_bg_seed543_nstart500.csv"),
            paste0(bg, basin59, "idx_table_60k_59_1173421_bg_seed1234_nstart500.csv"),
            
            # Basin 75_560810
            paste0(bo, basin75, "idx_table_60k_75_560810_bo_seed256_nstart500.csv"),
            paste0(bo, basin75, "idx_table_60k_75_560810_bo_seed543_nstart500.csv"),
            paste0(bo, basin75, "idx_table_60k_75_560810_bo_seed1234_nstart500.csv"),
            paste0(bg, basin75, "idx_table_60k_75_560810_bg_seed256_nstart500.csv"),
            paste0(bg, basin75, "idx_table_60k_75_560810_bg_seed543_nstart500.csv"),
            paste0(bg, basin75, "idx_table_60k_75_560810_bg_seed1234_nstart500.csv"),
            
            # Basin 20_1320241
            paste0(bo, basin20, "idx_table_60k_20_1320241_bo_seed256_nstart500.csv"),
            paste0(bo, basin20, "idx_table_60k_20_1320241_bo_seed543_nstart500.csv"),
            paste0(bo, basin20, "idx_table_60k_20_1320241_bo_seed1234_nstart500.csv"),
            paste0(bg, basin20, "idx_table_60k_20_1320241_bg_seed256_nstart500.csv"),
            paste0(bg, basin20, "idx_table_60k_20_1320241_bg_seed543_nstart500.csv"),
            paste0(bg, basin20, "idx_table_60k_20_1320241_bg_seed1234_nstart500.csv"),
            
            # Basin 47_481455
            paste0(bo, basin47, "idx_table_60k_47_481455_bo_seed256_nstart500.csv"),
            paste0(bo, basin47, "idx_table_60k_47_481455_bo_seed543_nstart500.csv"),
            paste0(bo, basin47, "idx_table_60k_47_481455_bo_seed1234_nstart500.csv"),
            paste0(bg, basin47, "idx_table_60k_47_481455_bg_seed256_nstart500.csv"),
            paste0(bg, basin47, "idx_table_60k_47_481455_bg_seed543_nstart500.csv"),
            paste0(bg, basin47, "idx_table_60k_47_481455_bg_seed1234_nstart500.csv"),
            
            # Basin 00_000006
            paste0(gg, basin06, "idx_table_60k_00_000006_gg_seed256_nstart500.csv"),
            paste0(gg, basin06, "idx_table_60k_00_000006_gg_seed543_nstart500.csv"),
            paste0(gg, basin06, "idx_table_60k_00_000006_gg_seed1234_nstart500.csv"))
            

# Input data --------------------------------------------------------------

first <- TRUE
for(i in 1:39){
  
  idx_tbl <- read_csv(files[i])
  
  file_name <- strsplit(files[i], split = "/")[[1]][[12]]
  cunit <- strsplit(file_name, split ="_")[[1]][[4]]
  basinID <- strsplit(file_name, split ="_")[[1]][[5]]
  vset <- strsplit(file_name, split ="_")[[1]][[6]]
  rnum <- strsplit(file_name, split ="_")[[1]][[7]]
  rnum <- as.numeric(str_extract(rnum, "[0-9]+"))
  nstr <- strsplit(file_name, split ="_")[[1]][[8]]
  nstr<- as.numeric(str_extract(nstr, "[0-9]+"))

  bst_ncl <- idx_tbl %>% 
    filter(indices == "davies_bouldin") %>% 
    mutate(bst_val= min(values)) %>% 
    filter(bst_val==values) %>% 
    select(.,-bst_val) %>% 
    mutate(CompUnit = cunit,
           BasinID = basinID,
           Set = vset,
           SEED = rnum,
           NSTART = nstr) %>% 
    rename(NCL = k) %>% 
    select(CompUnit, BasinID, Set, SEED, NSTART, NCL)
  
  if(first == TRUE){
    
    tbl <- bst_ncl
    first <- FALSE
    
  }else{
    
    tbl <- tbl %>% 
      bind_rows(bst_ncl)
    
  }
  
}

tbl <- as.data.table(tbl)
path <- "/my/working/directory/data/partitional_clustering/"
fwrite(tbl, paste0(path, "/bst_ncl.txt"), sep =" ")

# Exit R ------------------------------------------------------------------

quit(save = "no")
