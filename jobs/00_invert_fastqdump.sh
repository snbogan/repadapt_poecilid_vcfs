#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=00_invert_fastqdump
#SBATCH --time=7-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=00_invert_fastqdump_out/out_%A_%a.out
#SBATCH --error=00_invert_fastqdump_err/err_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=30G
#SBATCH --array=1-397

# Move to working directory
cd /hb/home/snbogan/RepAdapt/invert_vcfs/000_fastp/

# Load dependencies
module load sratoolkit

# Setup directories
BASE_DIR="$PWD/sra_data"
mkdir -p "$BASE_DIR" logs

# Merge and label accessions (assumes accession lists already exist)
cd "$BASE_DIR" || exit
awk '{print "PRJNA867688\t"$0}' PRJNA867688_accessions.txt > combined_accessions.txt
awk '{print "PRJNA674711\t"$0}' PRJNA674711_accessions.txt >> combined_accessions.txt

# Determine which SRR this array task handles
LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" combined_accessions.txt)
PROJECT=$(echo "$LINE" | cut -f1)
SRR=$(echo "$LINE" | cut -f2)

# Skip if SRR or project is empty
if [ -z "$SRR" ] || [ -z "$PROJECT" ]; then
    echo "No SRR found for task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

# Define output directory
OUTDIR="$BASE_DIR/$PROJECT"
mkdir -p "$OUTDIR"

echo "=== Task $SLURM_ARRAY_TASK_ID downloading $SRR from $PROJECT ==="

# Download and convert
prefetch --max-size 200G "$SRR" || { echo "Prefetch failed for $SRR"; exit 1; }

fasterq-dump "$SRR" --threads $SLURM_CPUS_PER_TASK -O "$OUTDIR" || { echo "FASTQ dump failed for $SRR"; exit 1; }

gzip "$OUTDIR"/*.fastq

# Clean up cached SRA file
rm -rf "$HOME/ncbi/public/sra/$SRR.sra"

echo "=== Completed $SRR from $PROJECT ==="
