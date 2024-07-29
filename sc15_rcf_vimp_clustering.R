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


# Define computational unit
cu <- c(rep("00", 3), rep(c("102", "88", "59", "75", "20", "47"), 6))
# Define basin ID
id <-  c(rep("000006", 3), rep(c("812813", "649217", "1173421", 
                                 "560810", "1320241", "481455"), 6))

# Define the set of variables
set <- c(rep("GG", 3), rep("BG", 18), rep("BO", 18)) 

rnum <- c(256, 543, 1234, rep(256,6), rep(543, 6), rep(1234,6), 
          rep(256,6), rep(543, 6),  rep(1234,6))
# Define nstart
nstart <- rep(500,39)

bst_ncl <- fread("/my/working/directory/data/partitional_clustering/bst_ncl.txt", keepLeadingZeros =TRUE)


for(n in c(1:39)){
  
  
  cunit <- cu[n]
  basinID <- id[n]
  vset <- set[n]
  nr <- rnum[n]
  nst <- nstart[n]
  
  ncl <- bst_ncl %>% 
    filter(CompUnit == cunit & BasinID == basinID & Set == vset & SEED == nr & NSTART == nst) %>% 
    .$NCL
  
# Directories -------------------------------------------------------------
  
# Define path

basin_path <- paste0("/my/working/directory/data/partitional_clustering/", 
                       vset, "/basin_", cunit, "_", basinID)


k_path <- paste0(basin_path, "/kmeans")

# Create paths for random forest output
rf_path <- paste0(basin_path, "/vimp")
if(!dir.exists(rf_path)) dir.create(rf_path)


# Input data --------------------------------------------------------------

# Load scaled environmental variables
basin <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", basinID, 
                      "_", vset, ".csv"))



# Load kmeans calculation
k <- read_rds(paste0(k_path, "/kmean_60k_", cunit, "_", basinID, "_",vset,
                     "_seed", nr, "_nstart", nst, ".rds"))
# Prepare data to run random forest ---------------------------------------

i <- paste0("n=", ncl)

rf_data <- basin[,4:ncol(basin)] %>% add_column(k[[i]]$cluster) %>% 
  rename(k = "k[[i]]$cluster") %>% 
  mutate(k = as.factor(k))


# Random forest -----------------------------------------------------------

t0 <- now()
rf <- rfsrc(k~., data = rf_data, ntree=500, importance = TRUE)
t1 <- finish_progress(i, t0, "rf")
print(t1)

# Save output --------------------------------------------------------------


write_rds(rf, paste0(rf_path, "/rf_", ncl, "k_",  cunit, "_", basinID, "_",vset,
                     "_seed", nr, "_nstart", nst, ".rds"))


# Create VIMP plot --------------------------------------------------------

vimp <- as.data.frame(rf$importance) %>% 
  rownames_to_column(., var = "variable") 

write_csv(vimp, paste0(rf_path, "/vimp_", ncl, "k_",  cunit, "_", basinID, "_",vset,
                       "_seed", nr, "_nstart", nst, ".csv"))
vimp <- vimp %>% 
  select(variable, all) %>% 
  mutate(rel_vimp = all/max(all)) %>% 
  arrange(rel_vimp) 

# Save tabel
write_csv(vimp, paste0(rf_path, "/rel_vimp_all_", ncl, "k_",  cunit, "_", basinID, "_",vset,
                       "_seed", nr, "_nstart", nst, ".csv"))


var_color <- ifelse(vimp$variable == "random", "red", "grey30")


vimp_plot <-  ggplot(vimp, aes(x = rel_vimp, y = fct_reorder(variable, rel_vimp))) +
             geom_col() +
              #geom_hline(aes(yintercept = "random", colour = "red")) +
              theme_bw() +
              theme(axis.title.y = element_blank(),
                    axis.text.y = element_text(colour = var_color),
                    axis.ticks = element_line(colour = var_color),
                    strip.placement = "outside",
                    strip.background = element_blank(),
                   strip.text.y = element_text(size = rel(1.1)),
                    legend.position  = "none") +
             xlab("Relative variable importance (-)")

# Create filename --------------------------------------------------------

filename <- paste0("rel_vimp_", ncl,"k", "_",  cunit, "_", basinID, "_",vset,
                   "_seed", nr, "_nstart", nst, ".png")

# Save output -------------------------------------------------------------

ggsave(filename, plot = vimp_plot, device= "png", path = rf_path, width= 15,
     height = 15, units = "cm", dpi = 300)

}
# Exit R ------------------------------------------------------------------

quit(save = "no")
