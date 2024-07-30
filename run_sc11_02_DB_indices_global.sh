#!/bin/bash
#SBATCH --job-name=cl_idx_global
#SBATCH -p week
#SBATCH -n 1 -c 20 -N 1
#SBATCH -t 7-00:00:00
#SBATCH -o /my/working/directory/stdout/cluster_indices_global.%A_%a.out
#SBATCH -e /my/working/directory/stderr/cluster_indices_global.%A_%a.err
#SBATCH --mem-per-cpu=5G
#SBATCH --array=2-13,15,16


export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )

export SEED=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $6}' )

export MINK=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $7}' )
export MAXK=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $8}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc11_02_DB_indices_global_slurm.R

exit
