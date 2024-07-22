#!/bin/bash
#SBATCH --job-name=kmean_global
#SBATCH -p scavenge
#SBATCH -n 1 -c 20 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /my/working/directory/stdout/partitional_clustering_global.%A_%a.out
#SBATCH -e /my/working/directory/stderr/partitional_clustering_global.%A_%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH --array=2-10

# Define computational unit, basin ID, variable set, random seed, number of starts, minimum number of clusters, and maximum number of clusters
export CUNIT=$( cat  /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat  /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat  /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

export SEED=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )

export MINK=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $6}' )
export MAXK=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $7}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc02_02_clustering_global_slurm.R

exit
