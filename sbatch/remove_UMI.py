import argparse

parser = argparse.ArgumentParser()
parser.add_argument("-i") #Input data path
parser.add_argument("-o") #output file

args = parser.parse_args()

in_file = args.i
ouf_file = args.o

#This function removes the last 6 bases from every read in a fastq file
#Both bases and quality score are trimmed.
#There is probably a better way to handle trimming with tRNA
#Especially in the context of piared end reads. But today is not the day
#C. Katanski, 2019 10 28
def remove_UMI(in_fastQ, out_file):
	#Name the output file in a manor similar to the input
	out_file = out_file
	out_handle = open(out_file, "w")

	#Read through input file line by line and strip stuff off
	with open(in_fastQ, "r") as in_file:
		for line in in_file.readlines():
			if line[0] == "@" or line[0] == "+": #don't strip from read names
				out_handle.write(line)
			#elif len(line)<6: #This shouldn't happen brecause reads are already filtered
			#	out_handle.write("\n")
			else:
				out_handle.write(line[:-6]+"\n")

	#Tidy up when you leave
	out_handle.close()


remove_UMI(args.i, args.o)
