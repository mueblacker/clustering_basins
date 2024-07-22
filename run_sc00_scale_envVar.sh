#!/bin/bash
#SBATCH --job-name=scale_envVar
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 0:20:00
#SBATCH -o /my/working/directory/stdout/scale_envVar.%A_%a.out
#SBATCH -e /my/working/directory/stderr/scale_envVar.%A_%a.err
#SBATCH --mem-per-cpu=20G
#SBATCH --array=2-8

# Define computational unit and basin ID
export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
#export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc00_scale_envVar_slurm.R

exit
