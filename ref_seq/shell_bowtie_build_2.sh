#!/bin/sh


REFERENCE_GENOME=bactFrag_638R-tRNAs_single_genes+5s.fa


INDEX_NAME="${REFERENCE_GENOME%.*}"
mkdir -p bowtie2_index/$INDEX_NAME
echo ./bowtie2_index/$INDEX_NAME/$INDEX_NAME

sbatch ./bowtie2_build.sbatch $REFERENCE_GENOME ./bowtie2_index/$INDEX_NAME/$INDEX_NAME


