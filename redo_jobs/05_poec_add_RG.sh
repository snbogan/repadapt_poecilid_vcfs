#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=05_poec_rg
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-160
#SBATCH --output=05_poec_rg_out/out_%A_%a.out
#SBATCH --error=05_poec_rg_err/err_%A_%a.err

# Move to wd
cd /data/colibri/kelley_lab/bogan/RepAdapt/05_rg/poec/

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list1_redo.txt) ### List of input deduplicated bam files
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list2_redo_cleaned.txt) ### List of output names (just remove .bam) from the inputs
NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list2_redo_cleaned.txt)   ### Here you want to extract the sample name from the input name, which is used to set the read IDs. Can be the same as list2.txt


### Here we add read groups, we start with our deduplicated bam files and we get a deduplicated bam with read groups assigned per sample/library
module load java
module load miniconda3
conda activate picard2.26.3

picard AddOrReplaceReadGroups I=$INPUT O=$OUTPUT\_RG.bam RGID=$NAME RGLB=$NAME\_LB RGPL=ILLUMINA RGPU=unit1 RGSM=$NAME
