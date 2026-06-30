#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=8_gam_cnv_2
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=8_gam_cnv_2_out/out_%A_%a.out
#SBATCH --error=8_gam_cnv_2_err/err_%A_%a.err

#### Calculate depth statistics for 1 samples ####

cd /data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/gam/

module load miniconda3
conda activate sam_bedtools_repadapt

# Input BAMs
INPUTS=(
"/data/colibri/kelley_lab/bogan/RepAdapt/07_realign_indel/gam/EFR22_278_S3_L004_realigned.bam"
)

OUTPUTS=(
"/data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/gam/EFR22_278_S3_L004"
)

INDEX=$((SLURM_ARRAY_TASK_ID-1))
INPUT=${INPUTS[$INDEX]}
OUTPUT=${OUTPUTS[$INDEX]}
file=$OUTPUT

# Dump depth of coverage at every position in the genome
samtools depth -aa "$INPUT" > "$OUTPUT.depth"

# Gene depth analysis
echo -e "\n>>> Computing depth of each gene for $file <<<\n"

awk '{print $1"\t"$2"\t"$2"\t"$3}' "$OUTPUT.depth" | \
bedtools map \
    -a /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genes.bed \
    -b stdin \
    -c 4 \
    -o mean \
    -null 0 \
    -g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genome.bed | \
awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | \
sort -k1,1 > "$OUTPUT-genes.tsv"

# Sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' \
    /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genes.list \
    "$OUTPUT-genes.tsv" > "$OUTPUT-genes.sorted.tsv"

# Window depth analysis
echo -e "\n>>> Computing depth of each window for $file <<<\n"

awk '{print $1"\t"$2"\t"$2"\t"$3}' "$OUTPUT.depth" | \
bedtools map \
    -a /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/windows.bed \
    -b stdin \
    -c 4 \
    -o mean \
    -null 0 \
    -g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genome.bed | \
awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | \
sort -k1,1 > "$OUTPUT-windows.tsv"

# Sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' \
    /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/windows.list \
    "$OUTPUT-windows.tsv" > "$OUTPUT-windows.sorted.tsv"

# Overall genome depth
echo -e "\n>>> Computing depth of whole genome for $file <<<\n"

awk '{sum += $3; count++} END {if (count > 0) print sum/count; else print "No data"}' \
    "$OUTPUT.depth" > "$OUTPUT-wg.txt"

echo ">>> Cleaning a bit..."
rm -f "$OUTPUT.depth"

echo "DONE! Check your files."
