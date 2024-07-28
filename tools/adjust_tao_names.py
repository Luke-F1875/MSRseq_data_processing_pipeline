import argparse
import time
import subprocess
import random
import os
#from Bio import SeqIO
import numpy as np
import time

parser = argparse.ArgumentParser()
#parser.add_argument("-i") #Input data path
parser.add_argument("-r") #reference file
parser.add_argument("-o") #output file name

args = parser.parse_args()

#in_file = args.i
ref_file = args.r
out_file = args.o


def read_fasta(ref_file):
	#read in reference fasta file
	with open(ref_file) as f:
		genes = f.readlines()

	#make a dictionary keyed by gene name values are catagories etc
	gene_list = []
	name=""
	for line in genes:
		if line[0] == ">":
			#If we starting a new gene (not initiatin), write the old gene
			if name !="":
				gene_list.append((name, sequence))

			#start a new gene
			name = line
			sequence = ""
			info = name.split()
		else:
			sequence += line
	return gene_list



def print_tidy(ref_file, out_file):
	gene_list = read_fasta(ref_file)
	
	with open(out_file, "w") as o:
		for entry in gene_list:
			tao_name = entry[0].strip().split()

			ID=tao_name[0] #Home_sapiens_chr6.trna95-AlaGC
			SEQTYPE="ncrna"
			CHROMOSOME="Chromosome:NA"
			GENE=ID.split(".")[-1]
			GENE_BIOTYPE="gene_biotype:tRNA"
			TRANSCRIPT_BIOTYPE="transcript_biotype:tRNA"
			GENE_SYMBOL="gene_symbol:"+GENE
			DESCRIPTION=entry[0][1:].strip() #drop the ">"

			name_to_write=ID+" "+SEQTYPE+" "+CHROMOSOME+" "+GENE+" "+GENE_BIOTYPE+" "+TRANSCRIPT_BIOTYPE+" "+GENE_SYMBOL+" "+DESCRIPTION

			o.write(name_to_write)
			o.write("\n")
			o.write(entry[1].strip())
			o.write("\n")



if __name__ == "__main__":
	print_tidy(ref_file, out_file)
