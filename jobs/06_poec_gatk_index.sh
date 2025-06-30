#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_gatk_index
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=poec_gatk_index.out
#SBATCH --error=poec_gatk_index.err

### This is to create gatk index of ref genome needed for indel realignment
### Keep the output files of this command in the same dir where you keep the reference genome fasta

# Move to wd
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/poec/

# Load modules
module load java/8u151
module load picard/2.27.1
module load samtools

# Index genome
samtools faidx rawg0041_Poecilia_mexicana_kelley.fasta

# Create dictionary
picard CreateSequenceDictionary R=rawg0041_Poecilia_mexicana_kelley.fasta O=rawg0041_Poecilia_mexicana_kelley.dict

