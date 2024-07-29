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
    paste("Completed", word, nmax, "in", .)
}


# Libraries ---------------------------------------------------------------

usePackage("data.table")
usePackage("tidyverse")
usePackage("lubridate")
usePackage("randomForestSRC")


# Select basin and dataset ------------------------------------------------
# Screening
# Define computational unit
cu <- c("102","88", "59","75", "47", "20", "00")
# Define basin ID
bid <-  c("812813", "649217", "1173421", "560810", "481455", "1320241",
           "000006")
# Define Seed
rn <- c(rep("256", 7))

nst <- c(rep(100, 7))
# Define the set of variables
set <- c(rep("screening", 7))

for(n in c(1:7)){
  
  cunit <- cu[n]
  basinID <- bid[n]
  vset <- set[n]
  rnum <- rn[n]
  nstart <- nst[n]
  
    # Directories
    # Define path
    basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                         vset, "/basin_", cunit, "_", basinID)
    
    k_path <- paste0(basin_path, "/kmeans")
    
    # Create paths for random forest output
    rf_path <- paste0(basin_path, "/vimp_classification")
    if(!dir.exists(rf_path)) dir.create(rf_path)
    
    
    # Input data 
    # Load scaled environmental variables
    basin <- fread(paste0(basin_path, "/basin_envVar_sc_",  cunit, "_", basinID, 
                          ".csv"))
    
    
    # Load kmeans calculation
    k <- read_rds(paste0(k_path, "/kmean_120k_", cunit, "_", basinID, 
                         "_", vset, "_seed", rnum, "_nstart", nstart, ".rds"))
    
    ncl_lkpt <- fread("/my/working/directory/partitional_clustering/bst_ncl_screening.txt")
      
    # Prepare data to run random forest
    id <- as.numeric(basinID)
    best_ncl <- ncl_lkpt %>%
      filter(BasinID == id & Set == vset & SEED == rnum, NSTART == nstart) %>% 
      .$NCL
    
    for(ncl in best_ncl){   
        i <- paste0("n=", ncl)
        
        
        rf_data <- basin[,4:ncol(basin)] %>% add_column(k[[i]]$cluster) %>% 
          rename(k = "k[[i]]$cluster") %>% 
          mutate(k = as.factor(k))
        
        
        # Random forest
        t0 <- now()
        rf <- rfsrc(k~., data = rf_data, ntree=500, importance = TRUE)
        t1 <- finish_progress(i, t0, "rf")
        print(t1)
        
       # Save output
        write_rds(rf, paste0(rf_path, "/rf_", ncl, "k_", cunit, "_", basinID, 
                             "_", vset, "_seed", rnum, "_nstart", nstart, ".rds"))
        
        
        
       # Create VIMP plot
       # plot(rf) 
        
       # Classification forest
        vimp <- as.data.frame(rf$importance) %>% 
          rownames_to_column(., var="variable") %>% 
          select(variable, all) %>% 
          mutate(rel_vimp = all/max(all)) %>% 
          arrange(rel_vimp) 
        
        # Regression forest
        # vimp <- bind_rows(rf$importance) %>% pivot_longer(., 1:ncol(.), names_to = "variable", 
                                                         # values_to = "vimp") %>% 
          #mutate(rel_vimp = vimp/max(vimp)) %>% 
         # arrange(rel_vimp) 
        
        
        
        vimp_plot <-  ggplot(vimp, aes(x = rel_vimp, y = fct_reorder(variable, rel_vimp))) +
                      geom_col() +
                     
                      theme_bw() +
                      theme(axis.title.y = element_blank(),
                            axis.text.y = element_text(colour = "grey30"),
                            axis.ticks = element_line(colour = "grey30"),
                            strip.placement = "outside",
                            strip.background = element_blank(),
                            strip.text.y = element_text(size = rel(1.1)),
                            legend.position  = "none") +
                      xlab("Relative variable importance (-)")
        
        ranking <- vimp %>% 
          arrange(desc(rel_vimp)) %>% 
          select(variable)
        
        
        # Create file names
        filename <- paste0("rel_vimp_", ncl,"k", "_", cunit, "_", basinID, 
                           "_", vset, "_seed", rnum, "_nstart", nstart, ".png")
        
        # Save output
        ggsave(filename, plot = vimp_plot, device= "png", path = rf_path, width= 15,
               height = 15, units = "cm", dpi = 300)
        
        fwrite(vimp, paste0(rf_path, "/vimp_", ncl, "k_",cunit, "_", basinID, 
                            "_", vset, "_seed", rnum, "_nstart", nstart, ".csv"))
        fwrite(ranking, paste0(rf_path, "/envVar_ranking_", cunit, "_", basinID, ".csv"))
    } 
print(n)
}
# Exit R ------------------------------------------------------------------

quit(save = "no")
