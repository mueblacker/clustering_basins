# Set working directory
setwd("/my/working/directory/data")

# Functions ---------------------------------------------------------------

# Function to check if the required packages are installed and to load the library
usePackage <- function(p){
  if (!is.element(p, installed.packages()[,1])) install.packages(p, dep = TRUE)
  library(p, character.only = TRUE)
}


sumlogic <- function(x, y, relation = "l") switch(relation, 
                                                   l = sum(x > y, na.rm = TRUE), se = sum(x <= y, na.rm = TRUE))

# Libraries ---------------------------------------------------------------

usePackage("data.table")
usePackage("tidyverse")
usePackage("doMC")
usePackage("foreach")
usePackage("fpc")

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
# Define number of cluster
ncl <-  as.numeric(Sys.getenv(c("NCL")))

# Directories -------------------------------------------------------------
# Define path
# Yale-Server
basin_path <- paste0("/my/working/directory/data/partitional_clustering/basins/", 
                     vset, "/basin_", cunit, "_", basinID)

k_path <- paste0(basin_path, "/kmeans")

stb_path <- paste0(basin_path, "/stability")
if(!dir.exists(stb_path)) dir.create(stb_path)

# Input data --------------------------------------------------------------
# Load scaled environmental variables
basin <- fread(paste0(basin_path, "/basin_envVar_sc_", cunit, "_", basinID, 
                      "_", vset, ".csv"))

# Load kmeans calculation
k <- read_rds(paste0(k_path, "/kmean_60k_", cunit, "_", basinID, "_", vset,
                     "_seed", rnum, "_nstart", nstr, ".rds"))



bsamp <- read_rds(paste0(stb_path, "/boot_samples_100B_", cunit, "_", basinID, 
                         "_", vset, "_seed", rnum, "_nstart", nstr, ".rds"))

bc1 <- read_rds(paste0(stb_path, "/kmean_boot_100B_", cunit, "_", basinID, 
                       "_", vset, "_seed", rnum, "_nstart", nstr, ".rds"))

# Prepare data ------------------------------------------------------------

# Convert data table to matrix
data <- as.matrix(basin[,4:ncol(basin)])


# Best k of the oringal kmeans calculation 
c1 <- k[[paste0("n=", ncl)]]
c1_list <- map(1:ncl, ~ k[[paste0("n=", ncl)]]$cluster == .x)

# Cluster stability -------------------------------------------------------

B <- 100
n <- nrow(data)
dissolution <-  0.5
recover <-  0.75


bootresult  <- matrix(0, nrow = ncl, ncol = B)

for(i in 1:B){
    bc1_list <- map(1:ncl, ~ bc1[[i]]$cluster == .x)
    
  for (j in 1:ncl) {
    maxgamma <- 0
      for (k in 1:ncl) {
        
        ncases <- 1:n
        cg <- clujaccard(c1_list[[j]][bsamp[[i]]][ncases], 
                         bc1_list[[k]][ncases], zerobyzero = 0)
        
        if (cg > maxgamma) 
          maxgamma <- cg
      
      }
    bootresult[j, i] <- maxgamma
  }

}   


bootmean = apply(bootresult, 1, mean, na.rm = TRUE)
bootbrd = apply(bootresult, 1, sumlogic, y = dissolution, 
                  relation = "se")
bootrecover = apply(bootresult, 1, sumlogic, y = recover, 
                      relation = "l")
  
cl_stab <- list(result = c1, partition = c1$cluster, nc = ncl, 
              B = B, dissolution = dissolution, recover = recover, bootresult = bootresult, 
              bootmean = bootmean, bootbrd = bootbrd, bootrecover = bootrecover)

# Create result tables ----------------------------------------------------

cl_boot <- as_tibble(cl_stab[[8]]) %>% 
  mutate(stability = case_when(
    value >= 0.85 ~ "highly stable",
    value >= 0.75 & value <= 0.85 ~ "valid stable",
    value >= 0.6 & value <= 0.75 ~ "pattern exist",
    value < 0.6 ~ "unstable")) %>% 
  group_by(stability) %>% 
  count(stability) %>% 
  mutate(CompUnit = cunit,
         BasinID = basinID,
         Set = vset,
         seed = rnum,
         nstart = nstr,
         bst_ncl = ncl) %>%
  rename(n_boot = n) %>% 
  select(CompUnit, BasinID, Set, seed, nstart, bst_ncl, stability, n_boot)


n_boot <- as_tibble(cl_stab[[8]]) %>% 
  mutate(CompUnit = cunit,
         BasinID = basinID,
         Set = vset,
         seed = rnum,
         nstart = nstr,
         bst_ncl = ncl) %>% 
  filter(value >=0.75) %>% 
  group_by(CompUnit, BasinID, Set, seed, nstart, bst_ncl) %>% 
  mutate(n = 1) %>% 
  summarize(STBL_BOOT = sum(n))


# Save boot result --------------------------------------------------------
write_rds(cl_stab, paste0(stb_path, "/cluster_stability_boot_", cunit, "_", 
                          basinID, "_", vset ,"_seed", rnum, "_nstart",
                          nstr, ".rds"))
write_csv(cl_boot,  paste0(stb_path, "/n_stable_cl_boot_", cunit, "_", 
                           basinID, "_", vset ,"_seed", rnum, "_nstart",
                           nstr, ".csv"))



file.create(paste0(stb_path, "/cluster_stability_boot_", cunit, "_", basinID, "_", 
                   vset ,"_seed", rnum, "_nstart", nstr, ".txt"))
sink(paste0(stb_path, "/cluster_stability_boot_", cunit, "_", basinID, "_", 
            vset ,"_seed", rnum, "_nstart", nstr, ".txt"))
print(cl_stab)
sink()

path <- "/my/working/directory/data/partitional_clustering"

if(!file.exists(paste0(path,  "/bst_ncl_stbl_boot.txt"))){
  write.table(x = n_boot, file = paste0(path, "/bst_ncl_stbl_boot.txt"), append = T,
              col.names = TRUE, row.names = FALSE, quote = FALSE)
}else{
  write.table(x = n_boot, file = paste0(path, "/bst_ncl_stbl_boot.txt"), append = T,
              col.names = FALSE, row.names = FALSE, quote = FALSE)
}

# Exit R ------------------------------------------------------------------

quit(save = "no")
