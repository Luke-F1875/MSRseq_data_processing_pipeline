#!/bin/sh

reference=./ref_seq/bowtie2_index/Mouse_tRNA_rRNA_snRNA_reference2/Mouse_tRNA_rRNA_snRNA_reference2
rm $reference.fai

index_file="${reference##*/}"
index_file="${index_file%%.[^.]*}"
echo $index_file
mkdir -p 6_sam_counter/$index_file
suffix=_abundance.tsv

for fullpath in ./3_bowtie2/$index_file/*.sam
do
sleep 0.01

filename="${fullpath##*/}"    # Strip longest match of */ from start
base="${filename%%.[^.]*}"    #Strip everything after the first period

echo "#!/bin/bash
#SBATCH --account=pi-taopan
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --partition=caslake
#SBATCH --mem-per-cpu=2000
#SBATCH --job-name=kallisto
#SBATCH --output=./6_sam_counter/$index_file/kallisto.out
#SBATCH --error=./6_sam_counter/$index_file/kallisto.err

module load python


python3 ./tools/sam_counter.py -i $fullpath -o ./6_sam_counter/$index_file/$base.tsv

sleep 1

#python3 ./removemRNA.py -i ./6_sam_counter/$index_file/$base.tsv

">./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
