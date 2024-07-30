#!/bin/bash
#SBATCH --job-name=cl_indices
#SBATCH -p scavenge
#SBATCH -n 1 -c 30 -N 1
#SBATCH -t 07:00:00
#SBATCH -o /my/working/directory/stdout/cluster_indices.%A_%a.out
#SBATCH -e /my/working/directory/stderr/cluster_indices.%A_%a.err
#SBATCH --mem-per-cpu=5G
#SBATCH --array=2-39
#SBATCH --requeue


export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt  | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt  | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

export SEED=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt  | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc11_01_DB_indices_slurm.R

exit
