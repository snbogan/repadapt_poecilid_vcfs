#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=06_ab_gatk_index
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=06_ab_gatk_index.out
#SBATCH --error=06_ab_gatk_index.err

### This is to create gatk index of ref genome needed for indel realignment
### Keep the output files of this command in the same dir where you keep the reference genome fasta

# Move to wd
cd /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/

# Load modules
module load miniconda3
conda activate samtools1.16.1

# Index genome
samtools faidx GCA_023055435.1_xgHalRufe1.0.p_genomic.fna

# Create dictionary
module load java
module load miniconda3
conda activate picard2.26.3

picard CreateSequenceDictionary R=GCA_023055435.1_xgHalRufe1.0.p_genomic.fna O=GCA_023055435.1_xgHalRufe1.0.p_genomic.dict

