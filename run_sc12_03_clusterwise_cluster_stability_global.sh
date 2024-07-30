#!/bin/bash
#SBATCH --job-name=cl_stab_glob
#SBATCH -p day
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 2:00:00
#SBATCH -o /my/working/directory/stdout/cluster_stability_global.%A_%a.out
#SBATCH -e /my/working/directory/stderr/cluster_stability_global.%A_%a.err
#SBATCH --mem-per-cpu=10G
#SBATCH --array=86-91


export CUNIT=$( cat /my/working/directory/data/partitional_clustering/bst_ncl.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $1}' )
export BID=$( cat //my/working/directory/data/partitional_clustering/bst_ncl.txt  | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $2}' )
export VSET=$( cat /my/working/directory/data/partitional_clustering/bst_ncl.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $3}' )

export SEED=$( cat /my/working/directory8/data/partitional_clustering/bst_ncl.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $4}' )
export NSTART=$( cat /my/working/directory/data/partitional_clustering/bst_ncl.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $5}' )
export NCL=$( cat /my/working/directory/data/partitional_clustering/bst_ncl.txt   | head -n $SLURM_ARRAY_TASK_ID | tail -1  | awk '{print $6}' )

module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc12_03_clusterwise_cluster_stability_global_slurm.R

exit
