#!/bin/sh

reference=./ref_seq/bowtie2_index/converted_hg38_CtoT/converted_hg38_CtoT

echo "#!/bin/bash
#SBATCH --job-name=bismark_BSreader
#SBATCH --partition=broadwl
#SBATCH -o ./bismark_BSreader.err
#SBATCH -e ./bismark_BSreader.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem-per-cpu=2000

sleep 1
module load midway2
module unload python
module load python

bismark --genome $reference /project2/taopan/7_chemical_method/tools/bismark-0.22.3/test_data.fastq
echo -e ""
"> ./sbatch/jobfile.sbatch

sbatch ./sbatch/jobfile.sbatch

done
