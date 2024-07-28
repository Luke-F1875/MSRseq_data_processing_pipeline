#!/bin/sh


REFERENCE_GENOME= streVene_ATCC10712-tRNAs_high_score_CCA+5S_3.fa


INDEX_NAME="${REFERENCE_GENOME%.*}"
mkdir -p bowtie2_index/$INDEX_NAME
echo ./bowtie2_index/$INDEX_NAME/$INDEX_NAME

sbatch ./bowtie2_build.sbatch $REFERENCE_GENOME ./bowtie2_index/$INDEX_NAME/$INDEX_NAME


