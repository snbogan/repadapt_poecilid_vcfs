#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=8_poec_cnv_2_remaining9
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-9
#SBATCH --output=8_poec_cnv_2_remaining9_out/out_%A_%a.out
#SBATCH --error=8_poec_cnv_2_remaining9_err/err_%A_%a.err

#### calculate depth statistics for selected samples ####

# Move to working directory
cd /data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/poec/

# Load modules
module load miniconda3
conda activate sam_bedtools_repadapt

# Create temporary filtered lists preserving the original order
grep -E 'MX13-001_S89_L004|MX13-003_S90_L004|MX13-116_S84_L004|MX13-117_S85_L004|MX13-118_S86_L004|MX13-270_S120_L004|MX13-272_S169_L004|MX13-273_S170_L004|MX13-274_S171_L004' \
08_list1_redo.txt > 08_list1_subset.txt

grep -E 'MX13-001_S89_L004|MX13-003_S90_L004|MX13-116_S84_L004|MX13-117_S85_L004|MX13-118_S86_L004|MX13-270_S120_L004|MX13-272_S169_L004|MX13-273_S170_L004|MX13-274_S171_L004' \
08_list2_redo.txt > 08_list2_subset.txt

INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list1_subset.txt)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list2_subset.txt)

# Dump depth of coverage at every position in the genome
samtools depth -aa "$INPUT" > "${OUTPUT}.depth"

# Gene depth analysis
echo -e "\n>>> Computing depth of each gene for ${INPUT} <<<\n"

awk '{print $1"\t"$2"\t"$2"\t"$3}' "${OUTPUT}.depth" | \
bedtools map \
    -a /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/genes.bed \
    -b stdin \
    -c 4 \
    -o mean \
    -null 0 \
    -g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/genome.bed | \
awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | \
sort -k1,1 > "${OUTPUT}-genes.tsv"

# Sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' \
    /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/genes.list \
    "${OUTPUT}-genes.tsv" \
    > "${OUTPUT}-genes.sorted.tsv"

# Window depth analysis
echo -e "\n>>> Computing depth of each window for ${INPUT} <<<\n"

awk '{print $1"\t"$2"\t"$2"\t"$3}' "${OUTPUT}.depth" | \
bedtools map \
    -a /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/windows.bed \
    -b stdin \
    -c 4 \
    -o mean \
    -null 0 \
    -g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/genome.bed | \
awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | \
sort -k1,1 > "${OUTPUT}-windows.tsv"

# Sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' \
    /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/windows.list \
    "${OUTPUT}-windows.tsv" \
    > "${OUTPUT}-windows.sorted.tsv"

# Overall genome depth
echo -e "\n>>> Computing depth of whole genome for ${INPUT} <<<\n"

awk '{sum += $3; count++}
     END {
         if (count > 0)
             print sum/count;
         else
             print "No data"
     }' "${OUTPUT}.depth" > "${OUTPUT}-wg.txt"

echo ">>> Cleaning up..."
rm -f "${OUTPUT}.depth"

echo "DONE! Check your files."
