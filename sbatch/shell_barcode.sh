#!/bin/sh

BARCODE=read2

mkdir -p 0_barcode_$BARCODE
#Don't change barcode path
bar_code_path=ref_seq/barcodes_4nt.txt
R1=_R1_001.fastq.gz
R2=_R2_001.fastq.gz


for fullpath in ./FastQ/*R2_001.fastq.gz
do
sleep 0.1

filename="${fullpath##*/}"
base="${filename%%.[^.]*}"
sample="${base%%_R*}"
#sample="${base}"


out=.out
err=.err

echo "#!/bin/bash
#SBATCH --account=pi-taopan
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=caslake
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=barcodee_splitting
#SBATCH --output=./0_barcode_$BARCODE/barcode_$sample$out
#SBATCH --error=./0_barcode_$BARCODE/barcode_$sample$err

module load java #/11.0.1
sleep 1


if [ $BARCODE == "read1" ]
then
#For read 1 barcode
./tools/je_1.2/je demultiplex F1=FastQ/$sample$R1 F2=./FastQ/$sample$R2 BF=$bar_code_path  BPOS=BOTH BM=READ_1 LEN=4:6 O=./0_barcode_read1/$sample FORCE=true C=false


elif [ $BARCODE == "read2" ]
then
#For read 2 barcode (note changes to "BM" and "LEN" fields#
./tools/je_1.2/je demultiplex F1=FastQ/$sample$R1 F2=FastQ/$sample$R2 BF=$bar_code_path  BPOS=BOTH BM=READ_2 LEN=6:4 O=./0_barcode_read2/$sample FORCE=true C=false

fi

echo $sample

"> ./sbatch/jobfile.sbatch
sbatch ./sbatch/jobfile.sbatch

done
