#!/bin/sh

reference=./ref_seq/SRP_db.fasta
rm $reference.fai

index_file="${reference##*/}"
index_file="${index_file%%.[^.]*}"
echo $index_file

mkdir -p 6_kallisto/$index_file
suffix=_abundance.tsv

for fullpath in ./2_fasta/*.fasta
do

    filename="${fullpath##*/}"    # Strip longest match of */ from start
    base="${filename%%.[^.]*}"    #Strip everything after the first period
    #sbatch sbatch/kallisto1.sbatch $reference $filename

echo "#!/bin/bash
#SBATCH --job-name=kallisto
#SBATCH -o ./6_kallisto/$index_file/kallisto.out
#SBATCH —e ./6_kallisto/$index_file/kallisto.err
#SBATCH --partition=broadwl
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2000

module load midway2; module load java/11.0.1


mkdir -p ./6_kallisto/$index_file/$base
./tools/kallisto/kallisto-0.46.1/src/kallisto quant -i ./ref_seq/bowtie2_index/$index_file/$index_file.idx  -o ./6_kallisto/$index_file/$base --single -l 40 -s 20 -t 4  $fullpath


mv ./6_kallisto/$index_file/$base/abundance.tsv  ./6_kallisto/$index_file/$base$suffix
#rm -r ./6_kallisto/$index_file/$base

">./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
