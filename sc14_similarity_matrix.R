# Set working directory
setwd("/my/working/directory/data/partitional_clustering/")

# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}

# Libraries ---------------------------------------------------------------

usePackage("tidyverse")

# Select basin ------------------------------------------------------------

# Define computational unit
cu <- c("102", "88", "59", "75", "20", "47")
# Define basin ID
id <-  c("812813", "649217", "1173421", "560810", "1320241", "481455")

# Define nstart
nst <- rep(500,6)

for(n in c(1:6)){
  
  cunit <- cu[n]
  basinID <- id[n]
  nstart <- nst[n]
  
  path <- "/my/working/directory/data/partitional_clustering"
  file <- c(paste0(path, "/bo/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bo_seed256_nstart", nstart, ".csv"),
            paste0(path, "/bo/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bo_seed543_nstart", nstart, ".csv"),
            paste0(path, "/bo/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bo_seed1234_nstart", nstart, ".csv"),
            
            paste0(path, "/bg/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bg_seed256_nstart", nstart, ".csv"),
            paste0(path, "/bg/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bg_seed543_nstart", nstart, ".csv"),
            paste0(path, "/bg/basin_", 
                   cunit, "_", basinID, "/reclassify/subcID_cl_", 
                   cunit, "_", basinID, "_", "bg_seed1234_nstart", nstart, ".csv"),
            
            paste0(path, "/gg/basin_00_000006/reclassify/subcID_cl_", 
                   cunit,  "_000006_gg_seed256_nstart", nstart, ".csv"),
            paste0(path, "/gg/basin_00_000006/reclassify/subcID_cl_", 
                   cunit, "_000006_gg_seed543_nstart", nstart, ".csv"),
            paste0(path, "/gg/basin_00_000006/reclassify/subcID_cl_",  
                   cunit,  "_000006_gg_seed1234_nstart", nstart, ".csv"))
  
  path_out <- "/my/working/directory/data/partitional_clustering/similarity"
  if(!dir.exists(path_out)) dir.create(path_out)
  
  # Built similarity matrix -------------------------------------------------
  
  # Create matrix
  runs<- c("bo256","bo543","bo1234", "bg256", "bg543", "bg1234", "gg256", 
           "gg543", "gg1234")
  similarity_matrix <- matrix(data = NA, nrow = 9, ncol = 9, 
                              dimnames = list(c(runs), 
                                              c(runs)))
  print("Start for-loop")
  
 for(i in c(1:9)){
    for(j in c(1:9)){
      
      clustering1 <- read_csv(file[i])
      clustering2 <-read_csv(file[j])     
      
      df <- inner_join(clustering1 , clustering2, by = "subcID")
      n_row <- nrow(df)
      
      k1 <- length(unique(df[[2]]))
      k2 <- length(unique(df[[3]]))
      

      df_names <- c("subcID", "cl1", "cl2")
      sim1 <- df %>% 
        set_names(df_names) %>% 
        select(subcID, cl1, cl2) %>% 
        group_by(cl1, cl2) %>% 
        count() %>% 
        group_by(cl1) %>% 
        filter(n == max(n)) %>% 
        ungroup() %>% 
        #mutate(n = 100*n/n_row) %>% 
        #arrange(cl2) %>% 
        #set_names(c("bo543", "gg543", "n_pixel"))
        #group_by(cl2) %>% 
        #mutate(f = n/sum(n))
        summarise(per_sim =sum(n)/(n_row/100)) %>% 
        .$per_sim
       
           
           if(i == j){
             similarity_matrix[i,j] <- NA
             
           }else{
             similarity_matrix[i,j] <- sim1
           }
           
    }
  }
  
  print("Finished for-loop")
  
  # Save output -------------------------------------------------------------
  
  similarity_tbl <- as.data.frame(similarity_matrix) %>% 
    rownames_to_column(., var = "Run")
  
  file_name <- paste0("similarity_matrix_", cunit, "_", basinID, "_nstart",
                      nstart, ".csv")
  write_csv(similarity_tbl, paste0(path_out, "/", file_name))
  
}
# Exit R ------------------------------------------------------------------

quit(save = "no")

