#Sam to tRNA style stats

import argparse

import pysam
import pandas as pd
import time
import subprocess
import random
import os
from Bio import SeqIO
import numpy as np
import time
np.random.seed(0) #IMPORTANT IMPORTANT IMPORTANT


class GENOME(object):
	'''
	'''
	def __init__(self, ref_file, start_breaks, soft_clip=True):
		#Make a dictionart of genes read from a fasta file;
		#format the gene data storage for the bins (or breaks) we'll use
		self.soft_clip = soft_clip #Important for mapping stops and mutations
		self.gene_dict = self.fasta_to_genes(ref_file, start_breaks)

	def verify_vs_sam(self, in_file):
		#Check to see the names and lengths of genes in the "sam"
		#input file match our genes
		error_message  = "Number of reference sequences in sam file"
		error_message += "and reference file are not the same"
		error_message += "\nDid you match them correctly?"
		with pysam.AlignmentFile(in_file, 'r') as samfile:
			try:
				assert samfile.nreferences == len(self.gene_dict.keys())
			except:
				print(error_message)
			try: 
				for name in samfile.references:
					assert name in self.gene_dict.keys()
			except:
				print("A sequence in the sam file isn't in the reference")



	def process_sam_file(self, in_file):
		#Read through the reads in the sam file. Add them to the "gene" objects
		#using pysam objects
		self.verify_vs_sam(in_file) #Check that the reference sequences are good

		with pysam.AlignmentFile(in_file, 'r') as samfile:
			i=0
			tic = time.time()

			for read in samfile.fetch():
				#check flag; rules out reverse complement, no match, multiple matches
				if read.flag == 0:
					#If its a mapped read, add it to the genome
					self.add_read(read)
				#Time keeping
				# i+=1
				# if i %10000 ==0:
				# 	toc(tic, "for the "+str(i)+"th read")
				# if i %10000 ==0:
				# 	break


	def print_tsv(self, out_file):
		#print all the data to a nice, R-friendly, tsv document
		with open(out_file, "w") as output:
			#Grab any random data dict and write the header
			HEADER=True #Part of printing the header only once
			for gene, gene_object in self.gene_dict.items():
				for bin_tuple, data_bin in gene_object.data_bin.items():
					pd.DataFrame(data_bin).to_csv(output, index=False, sep="\t",header=HEADER)
					#Make sure header is only printed the first time
					if HEADER==True:
						HEADER=False


	def fasta_to_genes(self, ref_file, start_breaks):
		#take fasta entrys and make gene objects
		record_dict = SeqIO.index(ref_file, "fasta") #usind .index is probably overkill
		SEQ_DICT = {} 
		for key, value in record_dict.items(): 
			SEQ_DICT[key] = gene_object(value, start_breaks)
		record_dict.close()
		return SEQ_DICT

	def add_read(self, sam_entry):
		#Take a sam entry, decide which gene it goes to, and pass it off
		self.gene_dict[sam_entry.reference_name].add_read(sam_entry, self.soft_clip)


class gene_object(object):
	'''
	'''
	def __init__(self, bio_object, start_breaks):
		self.name = bio_object.name
		self.sequence = str(bio_object.seq)
		self.length = len(self.sequence)
		self.data_bin_dict = self.get_data_bins_dict(start_breaks)
		self.data_bin = self.make_data_frames()

	def get_data_bins_dict(self, start_breaks):
		#a dict with keys 0 to len(sequence) and values of tuples
		#corresponding to start and stop of read_start_bins
		gene_bin_breaks = start_breaks #prepare for some bespoke bining
		if 0 not in gene_bin_breaks:
			gene_bin_breaks.append(0)
		#Sort the list to put zero at the front, put seq length at the back
		gene_bin_breaks = sorted(gene_bin_breaks)
		gene_bin_breaks.append(self.length+1)
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

	def make_data_frames(self):
		#For each bin, initialize a pandas data frame, populated with zeros
		#for pileup, starts, stops, insertions, deletions, ATCG, mutation
		data_frame_dict= {}
		for bin_tuple in self.data_bin_dict.values():
			data_frame_dict[bin_tuple] = {
				"sequence":list(self.sequence), #I know that this is redundant. Fight me?
				"starts": [0]*self.length,
				"stops": [0]*self.length,
				"pileup": [0]*self.length,
				"mutation": [0]*self.length,
				"A": [0]*self.length,
				"T": [0]*self.length,
				"C": [0]*self.length,
				"G": [0]*self.length,
				"N": [0]*self.length,
				"insertions": [0]*self.length,
				"deletions": [0]*self.length,
				"soft_clip": [0]*self.length,
				"bin_start": [bin_tuple[0]]*self.length,
				"bin_stop": [bin_tuple[1]]*self.length,
				"position": range(1, self.length+1),
				"gene_name": [self.name]*self.length
				} 
		return data_frame_dict

	def add_read(self, sam_entry, soft_clip=True):
		#This function takes a mapped read from a "sam" file
		#And adds its information to the binned data

		#Decide which bin base on 3' end of the read
		temp_data_bin = self.data_bin[self.data_bin_dict[sam_entry.reference_end]]

		#assemble the CIGAR expanded list
		cigar_list = []
		for stretch  in sam_entry.cigartuples:
			for i in range(stretch[1]):
				cigar_list.append(stretch[0])
		
		#assemble a list of reference positions for every CIGAR entry
		reference_position_list = []
		holder = sam_entry.get_reference_positions()
		holder.append(holder[-1]) #for soft clip 3' bases
		for thing in cigar_list:
			if thing == 0: #match or mismatch
				reference_position_list.append(holder[0])
				holder.pop(0)
			if thing == 4: #soft clip
				reference_position_list.append(holder[0])
			if thing == 1: #insertion
				reference_position_list.append(holder[0])
			if thing == 2: #deletion
				pass
				#reference_position_list.append(holder[0])

		assert len(holder)==1, "Logic of CIGAR expansion is borken"

		#loop update the data
		ref_index = 0
		query_index = 0
		for i in range(len(cigar_list)):
			cigar_pos = cigar_list[i]
			ref_pos = reference_position_list[ref_index]
			if cigar_pos == 0:
				quer_pos = sam_entry.query_sequence[ref_index]
				#if its an alignment, determine match or mismatch
				if quer_pos == self.sequence[ref_pos]:
					#its a match!
					temp_data_bin["pileup"][ref_pos] += 1 #pileup
					temp_data_bin[quer_pos][ref_pos] +=1 #individual nt
				else:
					#its a mismatch!
					temp_data_bin["pileup"][ref_pos] +=1 #pileup
					temp_data_bin[quer_pos][ref_pos] +=1 #individual nt
					temp_data_bin["mutation"][ref_pos] +=1
			if cigar_pos == 4: #soft clip
				temp_data_bin["soft_clip"][ref_pos] +=1
			if cigar_pos == 1: #insertion
				temp_data_bin["insertions"][ref_pos] +=1
				query_index -= 1
			if cigar_pos == 2: #deletion
				#Fill in for the missing base
				temp_data_bin["pileup"][query_index] +=1
				temp_data_bin["deletions"][query_index] +=1
				#Take care of the present base too
				#temp_data_bin["pileup"][ref_pos] +=1
				#temp_data_bin[quer_pos][ref_pos] +=1
				ref_index -= 1
				#Known bug here if there are >1 deletions in a row
			ref_index += 1
			query_index += 1

		#Record read start and stop
		temp_data_bin["starts"][sam_entry.reference_start] +=1
		temp_data_bin["stops"][sam_entry.reference_end -1] +=1 
		# ^ Note: Subtract 1 from index because indexing at 0 vs 1







#I long for the days of matlab and tic toc
#We'll have to make due
def toc(tic, text=""):
	if text !="":
		print(text)
	print(round(time.time() - tic,2))
	if text !="":
		print()

def main_program(in_file, ref_file, out_file, start_breaks):
	#Make the genome object
	tic = time.time()
	asdf = GENOME(ref_file, start_breaks)
	# toc(tic, "Initialize data frames")

	#process all the sam_files
	asdf.process_sam_file(in_file)
	# toc(tic, "Process all reads")

	#print to tsv
	asdf.print_tsv(out_file)



if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("-i") #Input data path
	parser.add_argument("-r") #reference file
	parser.add_argument("-o") #output file path
	parser.add_argument("-breaks") #pyhton style list of where to bin reads

	args = parser.parse_args()

	in_file = args.i
	ref_file = args.r
	out_file = args.o
	start_breaks = [0]
	if args.breaks is not None:
		start_breaks =  sorted([int(x) for x in args.breaks.split(",")])


	main_program(in_file, ref_file, out_file, start_breaks)


