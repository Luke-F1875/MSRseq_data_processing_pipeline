#!/bin/sh

reference=./ref_seq/HIV_genome.fasta
rm $reference.fai

index_file="${reference##*/}"
index_file="${index_file%%.[^.]*}"
echo $index_file

mkdir -p 7_fragment/$index_file
suffix=_fragment.tsv

for fullpath in ./3_bowtie2/$index_file/*.sam
do
sleep 0.1

filename="${fullpath##*/}"    # Strip longest match of */ from start
base="${filename%%.[^.]*}"    #Strip everything after the first period

echo "#!/bin/bash
#SBATCH --job-name=fragment
#SBATCH -o ./7_fragment/$index_file/$sample_fragment.out
#SBATCH —e ./7_fragment/$index_file/$sample_fragment.err
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2000

module unload python
module load midway2; module load python/3.5.2


python3 ./tools/sam_to_tsv_tRF.py -i $fullpath -r $reference  -o ./7_fragment/$index_file/$base$suffix -breaks 0

">./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
