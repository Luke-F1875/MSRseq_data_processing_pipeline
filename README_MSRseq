#Hi, if you are reading this then it means you want to run this pipeline of
#MSR-seq. It is relatively simple to run. First make sure you have your data 
#in a FastQ file from the genomics core website and the files should be in the 
# fastq.gz format

<<com
	The pipeline then consists of running 4 programs one after the other. 
1)	shell_barcode.sh
2)	shell_bowtie2_read2only.sh
3)	shell_counter.sh
4)	shell_bam_sort_wig.sh
It is important before these are run to check and adjust the path names to the 
necessary files. To then run these files use the command shown below. Shell_barcode needs the
FastQ files and makes 0_barcode_read2 (make sure it is the right barcodes normally
barcodes_4nt.txt but might be different if older samples and may also have to change 
the LEN = part in read1 read 2 part normally will be like 6:4 or 4:6), but might have to
change depending on the length of the barcodes you are using. Shell_bowtie2 needs 
the refence to be In an .fa format and will make 3_bowtie2 folder. Shell_counter makes 
the 6_sam_counter files while shell_bam makes the 5_tsv files and 4_bam files.

Also an important note that if you are using a new reference sequence then you need 
to make a bowtie sequence by running shell_bowtie_build_2.sh.

to run the individual file you want do
./path/to/file
Normally it will look like
./sbatch/shell_restoffilename.sh

To check if it is running and to see how far through the file it is you can do

squeue --user=yourusername

If you then want to cancel the run you can do

scancel idnumber

Where the idnumber is the id number outputted when running the script. There is also 
a way to run these using chmod +x filename but idk what that is about right now

Please read the associated manuscript for more details regarding this pipeline
<<com
