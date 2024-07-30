#!/bin/bash
#SBATCH --job-name=kmean_global
#SBATCH -p scavenge
#SBATCH -n 1 -c 20 -N 1
#SBATCH -t 24:00:00
#SBATCH -o /my/working/directory/stdout/kmean_boot_global.%A_%a.out
#SBATCH -e /my/working/directory/stderr/kmean_boot_global.%A_%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH --array=3-16
#SBATCH --requeue

export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

export SEED=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )

export MINB=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $6}' )
export MAXB=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $7}' )

export NCL=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set_global.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $8}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc12_02_cluster_kmean_bootstrap_global_slurm.R

exit
