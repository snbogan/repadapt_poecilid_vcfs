#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=01_poec_fastp_pt1
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=01_poec_fastp_pt1_out/out_%A_%a.out
#SBATCH --error=01_poec_fastp_pt1_err/err_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=30G
#SBATCH --array=1-160

# Move to working directory
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/01_fastp/poec/

# THESE LISTS NEED TO FOLLOW THE SAME ORDER
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list5.txt)  # Raw R1 fastq
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list6.txt)  # Raw R2 fastq
OUTPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list7.txt) # Base name for output R1
OUTPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list8.txt) # Base name for output R2

# Load modules
module load fastp

# Trim with fastp using repaired reads
fastp -w 4 \
  -i $INPUT1 \
  -I $INPUT2 \
  -o ${OUTPUT1}_trimmed.fastq.gz \
  -O ${OUTPUT2}_trimmed.fastq.gz
