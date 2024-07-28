#!/bin/sh

for fullpath in ./FastQ/*.fastq
do

    filename="${fullpath##*/}"    # Strip longest match of */ from start

echo "#!/bin/bash
#SBATCH --job-name=gzip_data
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2000

module load midway2
gzip $fullpath

"> ./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
