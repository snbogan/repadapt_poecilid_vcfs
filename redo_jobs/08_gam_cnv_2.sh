#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=8_gam_cnv_2
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-40
#SBATCH --output=8_gam_cnv_2_out/out_%A_%a.out
#SBATCH --error=8_gam_cnv_2_err/err_%A_%a.err

#### calculate depth statistics for 40 samples ####

# Move to wg
cd /data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/gam/

# Load needed modules: samtools v.1.16.1   BEDtools v.2.27.1
module load miniconda3
conda activate sam_bedtools_repadapt

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list1_redo.txt)  ### list of realigned bam files
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 08_list2_redo.txt)  ### list of output names (remove input bam suffix; change path to 08_...)

# dump depth of coverage at every position in the genome
samtools depth -aa $INPUT > $OUTPUT\.depth

# gene depth analysis
echo \n">>> Computing depth of each gene for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a \
/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genes.bed -b stdin -c 4 -o mean -null 0 \
-g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1 > $OUTPUT\-genes.tsv

# sort gene depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genes.list $OUTPUT\-genes.tsv > $OUTPUT\-genes.sorted.tsv

# window depth analysis
echo \n">>> Computing depth of each window for $file <<<"\n
awk '{print $1"\t"$2"\t"$2"\t"$3}' $OUTPUT\.depth | bedtools map -a \
/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/windows.bed -b stdin -c 4 -o mean -null 0 \
-g /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/genome.bed | awk -F "\t" '{print $1":"$2"-"$3"\t"$4}' | sort -k1,1  > $OUTPUT\-windows.tsv

# sort window depth results based on input bed file
join -a 1 -e 0 -o '1.1 2.2' -t $'\t' /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/windows.list $OUTPUT\-windows.tsv > $OUTPUT\-windows.sorted.tsv

# overall genome depth
echo \n">>> Computing depth of whole genome for $file <<<"\n
awk '{sum += $3; count++} END {if (count > 0) print sum/count; else print "No data"}' $OUTPUT\.depth > $OUTPUT\-wg.txt

echo " >>> Cleaning a bit...
"
rm -rf $OUTPUT\.depth
echo "
DONE! Check your files"
