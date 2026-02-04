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

set -euo pipefail

cd /home/snbogan/repadapt/vcf/invert/01_fastp/

module load miniconda3
conda activate sratoolkit

BASE_DIR="$PWD/sra_data"
ACCESSIONS="$BASE_DIR/combined_accessions.txt"

LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$ACCESSIONS")
PROJECT=$(cut -f1 <<< "$LINE")
SRR=$(cut -f2 <<< "$LINE")

if [[ -z "$PROJECT" || -z "$SRR" ]]; then
    echo "No SRR for task ${SLURM_ARRAY_TASK_ID}"
    exit 1
fi

OUTDIR="$BASE_DIR/$PROJECT"
mkdir -p "$OUTDIR"

echo "=== Task $SLURM_ARRAY_TASK_ID downloading $SRR ==="

# Skip completed downloads
if [[ -f "$OUTDIR/${SRR}_1.fastq.gz" ]]; then
    echo "$SRR already downloaded — skipping"
    exit 0
fi

prefetch --max-size 200G "$SRR"

fasterq-dump "$SRR" \
    --threads "$SLURM_CPUS_PER_TASK" \
    --outdir "$OUTDIR" \
    --split-files

# Compress only this SRR's files
gzip "$OUTDIR/${SRR}"_*.fastq

# Clean cache
rm -f "$HOME/ncbi/public/sra/${SRR}.sra"

echo "=== Completed $SRR ==="
