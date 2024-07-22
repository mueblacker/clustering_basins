#!/bin/bash
#SBATCH --job-name=correlation
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 03:00:00
#SBATCH -o /my/working/directory/stdout/correlation_envVar.%A_%a.out
#SBATCH -e /my/working/directory/stderr/correlation_envVar.%A_%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH --array=2-8

# Define computational unit, basin ID and variable set
export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc01_correlation_envVar_slurm.R

exit
