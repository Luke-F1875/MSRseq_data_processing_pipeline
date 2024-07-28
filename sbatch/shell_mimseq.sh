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
ngsReadme="readme_files.txt"
control="invivo_DMminus"

# Add lines here to run your computations.
mimseq --species Hsap \
--cluster-id 0.95 \
--threads 4 \
--min-cov 0.0005 \
--max-mismatches 0.1 \
--control-condition ${control} \
--no-cca-analysis \
-n hek_mods_correl \
--out-dir 4_mimseq_results092922 ${ngsReadme}
