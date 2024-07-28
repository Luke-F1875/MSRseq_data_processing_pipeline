#!/bin/bash
#SBATCH --job-name=mimseq
#SBATCH -o mapping_stats_%A.out
#SBATCH -e mapping_stats_%A.err
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=15
#SBATCH --mem-per-cpu=2000

module load python 
source activate /home/npena/.conda/envs/mimseq

mimseq \
--species Hsap \
--cluster-id 0.95 \
--threads 15 \
--min-cov 0.0005 \
--max-mismatches 0.1 \
--control-condition HEK293T \
 -n hg38_test \
 --out-dir hg38_HEK239vsK562 \
 --max-multi 4 \
 --remap \
 --remap-mismatches 0.075 sampleData_HEKvsK562.txt
