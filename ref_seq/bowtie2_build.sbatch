#!/bin/bash
#SBATCH --account=pi-taopan
#SBATCH --job-name=bowtie2-index
#SBATCH --partition=caslake
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=5
#SBATCH --mem-per-cpu=5000
#SBATCH --job-name=barcodee_splitting
#SBATCH --output=./bowtie2_build.out
#SBATCH --error=./bowtie2_index/bowtie2_build.err

module load python

#/project/taopan/yichen/tools/bowtie2-2.3.3.1-linux-x86_64/bowtie2-build --threads 10 -f "$1" "$2"

../tools/bowtie2-2.3.3.1-linux-x86_64/bowtie2-build --threads 10 -f "$1" "$2"
#/project/taopan/yichen/tools/kallisto/kallisto index -k 11 -i $2.idx $1

../tools/kallisto/kallisto index -k 11 -i $2.idx $1
