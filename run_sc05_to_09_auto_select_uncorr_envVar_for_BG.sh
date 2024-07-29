#!/bin/bash
#SBATCH --job-name=aselect_uncorr
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 0:10:00
#SBATCH -o /my/working/directory/stdout/aselect_uncorr_envVar.%A_%a.out
#SBATCH -e /my/working/directory/stderr/aselect_uncorr_envVar.%A_%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH --array=2-8


export CUNIT=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )
export VSET2=$( cat /my/working/directory/data/partitional_clustering/CompUnit_BasinID_Set.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $8}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc06_to_09_auto_select_uncorr_envVar_for_BG_slurm.R

exit
