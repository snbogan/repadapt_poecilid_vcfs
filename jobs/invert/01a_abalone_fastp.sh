#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=01a_abalone_fastp
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=01a_abalone_fastp_out/out_%A_%a.out
#SBATCH --error=01a_abalone_fastp_err/err_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=30G
#SBATCH --array=1-257

# Move to working directory
cd /hb/home/snbogan/repadapt/vcf/invert/01_fastp/sra_data/abalone/

# THESE LISTS NEED TO FOLLOW THE SAME ORDER
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list1.txt)  # Raw R1 fastq
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list2.txt)  # Raw R2 fastq
OUTPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list3.txt) # Base name for output R1
OUTPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list4.txt) # Base name for output R2

# Load modules
module load fastp

# Trim with fastp using repaired reads
fastp -w 4 \
  -i $INPUT1 \
  -I $INPUT2 \
  -o ${OUTPUT1}_trimmed.fastq.gz \
  -O ${OUTPUT2}_trimmed.fastq.gz
