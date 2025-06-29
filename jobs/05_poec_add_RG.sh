#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_rg
#SBATCH --time=1-00:00:00
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-160
#SBATCH --output=poec_rg_out/out_%A_%a.out
#SBATCH --error=poec_rg_err/err_%A_%a.err

# Move to wd
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/05_rg/poec/

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list1.txt) ### List of input deduplicated bam files
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list2.txt) ### List of output names (just remove .bam) from the inputs
NAME=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 05_list2.txt)   ### Here you want to extract the sample name from the input name, which is used to set the read IDs. Can be the same as list2.txt


### Here we add read groups, we start with our deduplicated bam files and we get a deduplicated bam with read groups assigned per sample/library
module load java/8u151
module load picard/2.27.1
module load samtools

picard AddOrReplaceReadGroups I=$INPUT O=$OUTPUT\_RG.bam RGID=$NAME RGLB=$NAME\_LB RGPL=ILLUMINA RGPU=unit1 RGSM=$NAME
