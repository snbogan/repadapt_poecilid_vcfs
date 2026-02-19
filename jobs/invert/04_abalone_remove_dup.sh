#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=4_ab_dedup
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=40G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-257
#SBATCH --output=4_ab_dedup_out/out_%A_%a.out
#SBATCH --error=4_ab_dedup_err/err_%A_%a.err

# Load required modules
module load java
module load miniconda3
conda activate picard2.26.3

# Move to working directory
cd /hb/home/snbogan/repadapt/vcf/invert/04_dedup/abalone/

# Get input and output filenames from list
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 04_list1.txt)           # full path to sorted BAM
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 04_list2.txt)  # output prefix (no extension)

# Set output directory
OUTDIR=/hb/home/snbogan/repadapt/vcf/invert/04_dedup/abalone/

# Run Picard to remove duplicates
picard MarkDuplicates \
    INPUT="$INPUT" \
    OUTPUT="${OUTDIR}/${OUTPUT}_dedup.bam" \
    METRICS_FILE="${OUTDIR}/${OUTPUT}_dedup_metrics.txt" \
    VALIDATION_STRINGENCY=SILENT \
    REMOVE_DUPLICATES=true
