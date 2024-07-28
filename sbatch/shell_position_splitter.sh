#!/bin/sh

reference=./ref_seq/bowtie2_index/hg19CCA+mito_adjusted_names+5Setc_020321/hg19CCA+mito_adjusted_names+5Setc_020321
mkdir -p 3_bowtie2

index_file="${reference##*/}"
mkdir -p ./3_bowtie2/position_split
suffix=.sam



for fullpath in ./3*/*/*.sam 
do
sleep 0.1

echo $fullpath
#sample_dir="${fullpath#*/0_barcode*/}" #gets the file and enclosing director
#sample_dir="${sample_dir%%/[^/]*}" #remove the filename to get just directory
#bar_directory="${fullpath%/*.*}/"

#filename="${fullpath##*/}"    # Strip longest match of */ from start
#base="${filename%%.[^.]*}"    #Strip everything after the first period
#sample="${base%%_2*}"


#read="${bar_directory#*/}"
#read="${read%%/[^/]*}"
#read="${read##*_}"

#underscore="_"

#echo $bar_directory
#echo $sample_dir
#echo $base
#echo $sample
#echo $read
#echo $sample_dir$underscore$sample
#echo 

#Detect which read the barcode is on, and merge accordingly to orient the read as sense
#if [ $read == "read1" ]
#then
#in1=_1.txt.gz
#in2=_2.txt.gz
#elif [ $read == "read2" ]
#then
#in1=_2.txt.gz
#in2=_1.txt.gz
#else
#in1=_2.txt.gz
#in2=_1.txt.gz
#fi



echo "#!/bin/bash
#SBATCH --job-name=bowtie2
#SBATCH --partition=broadwl
#SBATCH -o ./asdf.out
#SBATCH -e ./asdf.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem-per-cpu=2000

sleep 0.1
module load midway2
module unload python
module load python

#./tools/bowtie2-2.3.3.1-linux-x86_64/bowtie2 -x $reference -U $bar_directory$sample$in1   -S ./3_bowtie2/$index_file/$sample_dir$underscore$sample$suffix -q -p 10 --local --no-unal
sleep 0.1
#python ./tools/sam_bin_split.py -i ./3_bowtie2/$index_file/$sample_dir$underscore$sample$suffix -o ./3_bowtie2/$index_file/  -breaks 0,10,20,30,40,50,60

python ./tools/position_splitter.py -i $fullpath -r ./ref_seq/hg19CCA+mito_adjusted_names+5Setc_020321.fa  -p ./ref_seq/interesting_positions_m1A58.tsv -o ./3_bowtie2/position_split/


echo -e "$sample_dir$underscore$sample"
echo -e ""
"> ./sbatch/jobfile.sbatch

sbatch ./sbatch/jobfile.sbatch

done
