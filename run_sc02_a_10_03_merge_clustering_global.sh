#!/bin/bash
#SBATCH --job-name=comb_kmeans
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 00:15:00
#SBATCH -o /my/working/directory/stdout/comb_kmeans_global.%A_%a.out
#SBATCH -e /my/working/directory/stderr/comb_kmeans_global.%A_%a.err
#SBATCH --mem-per-cpu=5G
#SBATCH --array=10

# Define computational unit, basin ID, variable set, random seed,and number of starts
export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

export SEED=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc02_a_10_03_merge_clustering_global_slurm.R

exit
