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

usePackage("data.table")
usePackage("tidyverse")
usePackage("ggplot2")

# Select basin and dataset ------------------------------------------------

# Define computational unit
cu <- c(rep("00", 3), rep(c(rep("102", 3), rep("88", 3), rep("59", 3), 
        rep("75", 3), rep("20", 3), rep("47", 3)),2))
# Define basin ID
bid <-  c(rep("000006", 3), rep(c(rep("812813", 3), rep("649217", 3), 
          rep("1173421", 3), rep("560810", 3), rep("1320241", 3), 
          rep("481455", 3)),2))
#
rn <-rep(c("256","543","1234"),13)

nst <- rep(500, 39)
# Define the set of variables
set <- c(rep("gg", 3), rep("bo", 18), rep("bg", 18))


for(n in c(1:39)){
  
  
  cunit <- cu[n]
  basinID <- bid[n]
  rnum <- rn[n]
  vset <- set[n]
  nstart <- nst[n]
  
  
# Directories -------------------------------------------------------------

idx_path  <- paste0("/my/working/directory/partitional_clustering/", 
                    vset, "/basin_", cunit, "_", basinID,  "/indices")

# Input data --------------------------------------------------------------

idx_tbl <- fread(paste0(idx_path, "/idx_table_60k_",cunit, "_", basinID, 
                        "_", vset, "_seed", rnum, "_nstart", nstart, ".csv"))

sse_dat <- fread(paste0(idx_path, "/norm_within_ssq_60k_", cunit, "_", basinID, 
                        "_", vset, "_seed", rnum, "_nstart", nstart, ".csv"))

print("Loaded table")


# Labeller for plot -------------------------------------------------------

# Labeller for indices
idx_name <- c(davies_bouldin = "Davies Bouldin", 
              tot.withinss = "Total Within Sum of Squares")


# Determine chord line and distance between chord line and SSW curve ------

# Get min. and max. number of cluster k
chord <- filter(sse_dat, k == min(k) | k == max(k)) %>%
  arrange(k) %>%
  as.matrix()

# Calculate distance to the curve using the function max_dist
sse_dat$max_diff <- apply(sse_dat, 1, max_dist, chord)


# Prepare data for the elbow plot -----------------------------------------

# Select k where the distance is the longest
k_max <- sse_dat$k[which(sse_dat$max_diff == max(sse_dat$max_diff, na.rm = T))]

# Data for the ssw and distance curve
cluster_data <- sse_dat %>%
  pivot_longer(., cols = -k) %>%
  mutate(name = factor(name,
                       levels = c("norm_within_ssq", 'max_diff'),
                       labels =  c("within SSE / total SSE", "Distance to chord line"))) %>%
  mutate(value = ifelse(is.nan(value), 0, value))

# Select row with the best number of clusters
select_dat <- cluster_data %>%
  filter(k == k_max)

# Data for the chord line
chord_data <- sse_dat %>%
  filter(., k == min(k) | k == max(k)) %>%
  arrange(k) %>%
  select(-max_diff) %>%
  mutate(name = factor("norm_within_sse", 
         labels = c("within SSE / total SSE")),
         value = norm_within_ssq)

# Define breaks on x-axes depending on the maximum number of clusters
int <- max(round(nrow(cluster_data)/10),1)
x_breaks <- seq(int, max(cluster_data$k), int)

# Create chord line and distance plot -------------------------------------


bstssq <- ggplot(data = cluster_data, aes(x = k, y = value)) +
          geom_line() +
          geom_point() +
          geom_line(data = chord_data, aes(x = k, y = value), linetype = "dotted") +
          geom_point(data = select_dat, aes(x = k, y = value), col = "red", size = 2) +
          scale_x_continuous(breaks = x_breaks, minor_breaks = 1:max(cluster_data$k)) +
          facet_grid(name~., switch = "both") +
          theme_bw() +
          theme(axis.title.y = element_blank(),
                strip.placement = "outside",
                strip.background=element_blank(),
                strip.text.y = element_text(size = rel(1.1))) +
          xlab("Number of clusters")


# Prepare data for indices plot -------------------------------------------

# Select best number of clusters for the ssw
bst_ssq <- idx_tbl %>%  filter(indices == "tot.withinss" & k == k_max)

tmp <- idx_tbl %>% 
  filter(indices != "tot.withinss") %>% 
  bind_rows(bst_ssq) 

# Depending on the indices select min or max value
bst_ncl <- tmp %>% 
  group_by(indices) %>% 
  mutate(bst_val=ifelse(indices == "davies_bouldin", min(values), max(values))) %>% 
  filter(bst_val==values) %>% 
  select(.,-bst_val) %>% 
  mutate(CompUnit = cunit,
         BasinID = basinID,
         Set = vset) %>% 
  select(CompUnit, BasinID, Set, indices, values, k)

# Define breaks on x-axes depending on the maximum number of clusters
int <- max(round(max(idx_tbl$k)/10),1)
x_breaks <- seq(int, max(idx_tbl$k), int)


# Create plot with all calculated indices ---------------------------------

idx_plot <-  ggplot(idx_tbl, aes(x = k, y = values)) +
             geom_line() +
             geom_point()+
             facet_wrap(.~indices, scales = "free", labeller = labeller(indices = idx_name))+
             scale_x_continuous(breaks = x_breaks, minor_breaks = 1:max(idx_tbl$k)) +
             geom_point(data = bst_ncl, aes(x = k, y = values), col = "red", size = 2) +
             theme_bw() +
             theme(axis.title.y = element_blank(),
                  strip.placement = "outside",
                  strip.background=element_blank(),
                  strip.text.y = element_text(size = rel(1.1))) +
             xlab("Number of clusters") 

# Create filenames --------------------------------------------------------

#ncl <- which(diff(diff(sse_dat$norm_within_ssq)) < 0)[1]+1
ncl <- sse_dat %>% filter(k==max(k)) %>% .$k

filename_idx <- paste0("indices_", ncl,"k", "_", cunit, "_", basinID, "_",
                       vset, "_seed", rnum, "_nstart", nstart, ".png")
filename_elbow <- paste0("elbow_", ncl,"k", "_", cunit, "_", basinID, "_", 
                         vset, "_seed", rnum, "_nstart", nstart, ".png")

# Save output -------------------------------------------------------------

ggsave(filename_idx, plot = idx_plot, device = "png", path = idx_path, width= 20, 
       height = 15, units = "cm", dpi = 300)
ggsave(filename_elbow, plot = bstssq, device= "png", path = idx_path, width= 15, 
       height = 10, units = "cm", dpi = 300)

fwrite(bst_ncl,paste0(idx_path, "/bst_ncl_", ncl,"k_", cunit, "_", basinID, "_",
                      vset, "_seed", rnum, "_nstart", nstart, ".csv"))

print("Created and saved indices plot:")
print(n)

}
# Exit R ------------------------------------------------------------------

quit(save = "no")
