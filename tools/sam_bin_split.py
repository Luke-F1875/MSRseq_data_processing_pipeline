#Sam to tRNA style stats

import argparse

import pysam
#import pandas as pd
#import time
#import subprocess
#import random
#import os
#from Bio import SeqIO
#import numpy as np
#import time
#np.random.seed(0) #IMPORTANT IMPORTANT IMPORTANT




def breaks_to_bins(start_breaks):
	#a dict with keys 0 to len(sequence) and values of tuples
	#corresponding to start and stop of read_start_bins
	gene_bin_breaks = start_breaks #prepare for some bespoke bining
	if -1 not in gene_bin_breaks:
		gene_bin_breaks.append(-1)
	if -2 not in gene_bin_breaks:
		gene_bin_breaks.append(-2)
	if 0 not in gene_bin_breaks:
		gene_bin_breaks.append(0)
	#Sort the list to put zero at the front, put seq length at the back
	gene_bin_breaks = sorted(gene_bin_breaks)
	gene_bin_breaks.append(200) #HARD CODED max size
	bins_tuples = []
	#Make start and stop pairs
	for i, number in enumerate(gene_bin_breaks[:-1]):
		bins_tuples.append((gene_bin_breaks[i], gene_bin_breaks[i+1]))
	#Make a dictionary of integers that sends you to the right bin
	return_dict={}
	for bin_tuple in bins_tuples:
		for i in range(bin_tuple[0], bin_tuple[1]):
			return_dict[i] = bin_tuple
	return return_dict




def recursive_file_open(in_file, out_file, file_bin_list, samfile, bins_dict, file_bin_dict={}):

	#Open a sam file for reads
	prefix = in_file.split("/")[-1].split(".")[0]
	bin_suffix = "_" + str(file_bin_list[0][0])+ "_" + str(file_bin_list[0][1]) + "_"
	suffix = ".sam"
	#print(prefix + bin_suffix + suffix)
	file_bin_dict[file_bin_list[0]] = pysam.AlignmentFile(out_file + prefix + bin_suffix + suffix, "w", template=samfile)
	#Call the funciton again unless we're at the end of the bin list
	if len(file_bin_list) > 1:
		recursive_file_open(in_file, out_file, file_bin_list[1:], samfile, bins_dict, file_bin_dict=file_bin_dict)
	#When we've opened an output file for ever bin, do the sorting of reads
	else:
		flag_dict={}
		#print(file_bin_dict)
		for read in samfile.fetch():
			flag_dict[read.flag] = flag_dict.get(read.flag, 0) +1
			if read.flag==16:#Updated for read2 only mapping  #read.flag == 83 or read.flag == 163 or read.flag==161 or read.flag ==81:#This might not be ideal
				#Find the read end; get the corresponding bin; get the corresponding file; write
				file_bin_dict[bins_dict[-2]].write(read)
				if read.reference_end >=200:
					#print("BAD, why >200?")
					continue
				file_bin_dict[bins_dict[read.reference_end]].write(read)
			if read.flag == 0: #updated for read2 only mapping #read.flag == 99 or read.flag == 147 or read.flag==97 or read.flag==145: #This puts reverse complement reads in their own bin
				file_bin_dict[bins_dict[-1]].write(read)
				#print((read.reference_start, read.reference_end, bins_dict[read.reference_end]))
			#This bin takes all reads (the minus 2 bin)
			#file_bin_dict[bins_dict[-2]].write(read)
		print(flag_dict)



def main_program(in_file, out_file, start_breaks):

	bins_dict = breaks_to_bins(start_breaks)
	file_bin_list = list(set(breaks_to_bins(start_breaks).values()))

	with pysam.AlignmentFile(in_file, 'r') as samfile:
		recursive_file_open(in_file, out_file, file_bin_list, samfile, bins_dict)



if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("-i") #Input data path
	parser.add_argument("-o") #output file path
	parser.add_argument("-breaks") #pyhton style list of where to bin reads

	args = parser.parse_args()

	in_file = args.i
	out_file = args.o
	start_breaks = [0]
	if args.breaks is not None:
		start_breaks = sorted([int(x) for x in args.breaks.split(",")])

	main_program(in_file, out_file, start_breaks)



