#!/bin/sh
reference=./ref_seq/hg38_chrtRNA_genesHighConfid_introRemoved_CCA.fa
rm $reference.fai


index_file="${reference##*/}"
index_file="${index_file%%.[^.]*}"
echo $index_file

mkdir -p 4_bam_sort_wig/$index_file
mkdir -p 5_tsv/$index_file

for fullpath in ./3_bowtie2/$index_file/*.sam
do
sleep 0.1
filename="${fullpath##*/}"    # Strip longest match of */ from start
#base="${filename%%.[^.]*}"    #Strip everything after the first period
base="${filename%%.[^.sam]}"
echo $base

echo "#!/bin/bash
#SBATCH --job-name=bam_sort_wig
#SBATCH -o ./4_bam_sort_wig/$index_file/bam_sort_wig_$base.out
#SBATCH -e ./4_bam_sort_wig/$index_file/bam_sort_wig_$base.err
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=8000


sleep 1
module unload python
module load midway2; module load python
module load java/11.0.1

filename="${fullpath##*/}"
base="${filename%%.[^.]*}"


./tools/samtools-1.10/samtools view -bS -o ./4_bam_sort_wig/$index_file/$base.bam ./3_bowtie2/$index_file/$filename
sleep 0.1
./tools/samtools-1.10/samtools sort ./4_bam_sort_wig/$index_file/$base.bam -o ./4_bam_sort_wig/$index_file/$base.sort.bam
sleep 0.1
./tools/IGV_2.8.0/igvtools count -z 5 -w 1 -e 250 --bases 4_bam_sort_wig/$index_file/$base.sort.bam 4_bam_sort_wig/$index_file/$base.wig $reference
sleep 0.1
python3 ./tools/wig_to_tsv_low_mem_2.py -i ./4_bam_sort_wig/$index_file/$base.wig -r $reference -o ./5_tsv/$index_file/$base.tsv

##python3 ./tools/basewise_add_names.py -i ./5_tsv/$index_file/$base.tsv -r $reference -o ./5_tsv/$index_file/$base.tsv #not needed for ecoli

sleep 0.1
#python3 ./tools/removemRNA.py -i ./5_tsv/$index_file/$base.tsv


">./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
