#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_dedup
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=40G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-160
#SBATCH --output=poec_dedup_out/out_%A_%a.out
#SBATCH --error=poec_dedup_err/err_%A_%a.err

# Load required modules
module load java/8u151
module load picard/2.27.1
module load samtools

# Move to working directory
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/04_dedup/poec/

# Get input and output filenames from list
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 04_list1.txt)           # full path to sorted BAM
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 04_list2_cleaned.txt)  # output prefix (no extension)

# Set output directory
OUTDIR=/hb/home/snbogan/RepAdapt/poecilid_vcfs/04_dedup/poec/
mkdir -p "$OUTDIR"

# Run Picard to remove duplicates
picard MarkDuplicates \
    INPUT="$INPUT" \
    OUTPUT="${OUTDIR}/${OUTPUT}_dedup.bam" \
    METRICS_FILE="${OUTDIR}/${OUTPUT}_dedup_metrics.txt" \
    VALIDATION_STRINGENCY=SILENT \
    REMOVE_DUPLICATES=true

# Index the deduplicated BAM
samtools index "${OUTDIR}/${OUTPUT}_dedup.bam"
