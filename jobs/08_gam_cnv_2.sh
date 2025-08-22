#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=gam_cnv
#SBATCH --time=12:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-40
#SBATCH --output=gam_cnv_out/out_%A_%a.out
#SBATCH --error=gam_cnv_err/err_%A_%a.err

#### calculate depth statistics for 40 samples ####

# Move to wg
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/08_cnv/gam/

# Load needed modules
module load samtools
module load bedtools

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list1.txt)  ### list of realigned bam files
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list2_cleaned.txt)  ### list of output names (remove input bam suffix; change path to 08_...)

# dump depth of coverage at every position in the genome
samtools depth -aa $INPUT > $OUTPUT\.depth

# gene depth analysis
echo \n">>> Computing depth of each gene for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a genes.bed -b stdin -c 4 -o mean -null 0 -g genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1 > $OUTPUT\-genes.tsv

# sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' genes.list $OUTPUT\-genes.tsv > $OUTPUT\-genes.sorted.tsv

# window depth analysis
echo \n">>> Computing depth of each window for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a windows.bed -b stdin -c 4 -o mean -null 0 -g genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1  > $OUTPUT\-windows.tsv

# sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' windows.list $OUTPUT\-windows.tsv > $OUTPUT\-windows.sorted.tsv

# overall genome depth
echo \n">>> Computing depth of whole genome for $file <<<"\n
awk '{sum += $3; count++} END {if (count > 0) print sum/count; else print "No data"}' $OUTPUT\.depth > $OUTPUT\-wg.txt

echo " >>> Cleaning a bit...
"
rm -rf $OUTPUT\.depth
echo "
DONE! Check your files"
