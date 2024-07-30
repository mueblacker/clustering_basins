#!/bin/bash
#SBATCH --job-name=bst_ncl
#SBATCH -p scavenge
#SBATCH -n 1 -c 1 -N 1
#SBATCH -t 00:10:00
#SBATCH -o /my/working/directory/stdout/create_table_with_ok.%A_%a.out
#SBATCH -e /my/working/directory/stderr/create_table_with_ok.%A_%a.err
#SBATCH --mem-per-cpu=10G


module load R/4.0.3-foss-2020b

R --slave -f /my/working/directory/code/cluster_analysis/sc11_03_create_table_with_ok_slurm.R

exit
