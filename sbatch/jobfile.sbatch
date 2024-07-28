#!/bin/bash
#SBATCH --account=pi-taopan
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --partition=caslake
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=barcodee_splitting
#SBATCH --output=./0_barcode_read2/barcode_Undetermined_S0.out
#SBATCH --error=./0_barcode_read2/barcode_Undetermined_S0.err

module load java #/11.0.1
sleep 1


if [ read2 == read1 ]
then
#For read 1 barcode
./tools/je_1.2/je demultiplex F1=FastQ/Undetermined_S0_R1_001.fastq.gz F2=./FastQ/Undetermined_S0_R2_001.fastq.gz BF=ref_seq/barcodes_4nt.txt  BPOS=BOTH BM=READ_1 LEN=4:6 O=./0_barcode_read1/Undetermined_S0 FORCE=true C=false


elif [ read2 == read2 ]
then
#For read 2 barcode (note changes to BM and LEN fields#
./tools/je_1.2/je demultiplex F1=FastQ/Undetermined_S0_R1_001.fastq.gz F2=FastQ/Undetermined_S0_R2_001.fastq.gz BF=ref_seq/barcodes_4nt.txt  BPOS=BOTH BM=READ_2 LEN=6:4 O=./0_barcode_read2/Undetermined_S0 FORCE=true C=false

fi

echo Undetermined_S0


