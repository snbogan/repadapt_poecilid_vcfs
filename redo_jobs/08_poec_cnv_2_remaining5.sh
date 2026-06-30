#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=8_poec_cnv_2_remaining5_retry
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-5
#SBATCH --output=8_poec_cnv_2_remaining5_retry_out/out_%A_%a.out
#SBATCH --error=8_poec_cnv_2_remaining5_retry_err/err_%A_%a.err

cd /data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/poec/

module load miniconda3
conda activate sam_bedtools_repadapt

grep -E 'MX13-001_S89_L004|MX13-003_S90_L004|MX13-116_S84_L004|MX13-117_S85_L004|MX13-118_S86_L004|MX13-270_S120_L004|MX13-272_S169_L004|MX13-273_S170_L004|MX13-274_S171_L004|MX13-208_S168_L004' \
08_list1_redo.txt > 08_list1_subset.txt

grep -E 'MX13-001_S89_L004|MX13-003_S90_L004|MX13-116_S84_L004|MX13-117_S85_L004|MX13-118_S86_L004|MX13-270_S120_L004|MX13-272_S169_L004|MX13-273_S170_L004|MX13-274_S171_L004|MX13-208_S168_L004' \
08_list2_redo.txt > 08_list2_subset.txt

case $SLURM_ARRAY_TASK_ID in
    1) LINE=1 ;;
    2) LINE=2 ;;
    3) LINE=6 ;;
    4) LINE=8 ;;
    5) LINE=10 ;;
esac

INPUT=$(sed -n "${LINE}p" 08_list1_subset.txt)
OUTPUT=$(sed -n "${LINE}p" 08_list2_subset.txt)

file=$INPUT

# dump depth of coverage at every position in the genome
samtools depth -aa $INPUT > $OUTPUT\.depth

# gene depth analysis
echo -e "\n>>> Computing depth of each gene for $file <<<\n"
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a genes.bed -b stdin -c 4 -o mean -null 0 -g genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1 > $OUTPUT\-genes.tsv

# sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' genes.list $OUTPUT\-genes.tsv > $OUTPUT\-genes.sorted.tsv

# window depth analysis
echo -e "\n>>> Computing depth of each window for $file <<<\n"
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a windows.bed -b stdin -c 4 -o mean -null 0 -g genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1 > $OUTPUT\-windows.tsv

# sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' windows.list $OUTPUT\-windows.tsv > $OUTPUT\-windows.sorted.tsv

# overall genome depth
echo -e "\n>>> Computing depth of whole genome for $file <<<\n"
awk '{sum += $3; count++} END {if (count > 0) print sum/count; else print "No data"}' $OUTPUT\.depth > $OUTPUT\-wg.txt

echo " >>> Cleaning a bit...
"
rm -rf $OUTPUT\.depth
echo "
DONE! Check your files"
