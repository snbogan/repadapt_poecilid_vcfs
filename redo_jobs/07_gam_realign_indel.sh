#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=07_gam_realign_indel_redo
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=60G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-40
#SBATCH --output=07_gam_realign_indel_out/07_gam_realign_indel_%A_%a.out
#SBATCH --error=07_gam_realign_indel_err/07_gam_realign_indel_%A_%a.err

# Move to wd 1
cd /data/colibri/kelley_lab/bogan/RepAdapt/07_realign_indel/gam/

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list1_redo.txt) ### list of bam files with read groups (output of script 05)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list2_redo.txt)  ### list of output names (just remove .bam suffix from input list)

module load miniconda3
conda activate samtools1.16.1

# Move to wd 2
cd /data/colibri/kelley_lab/bogan/RepAdapt/05_rg/gam/

# Index rg bam files
samtools index $INPUT

conda deactivate
module purge

# Move to wd 1
cd /data/colibri/kelley_lab/bogan/RepAdapt/07_realign_indel/gam/

### Here we generate a indel realigned bam file for each sample/library
module load java
module load miniconda3
conda activate gatk_v3.8

GenomeAnalysisTK -T RealignerTargetCreator \
 -R /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/rawg0043_Gambusia_sexradiata_kelley.fasta \
 -I $INPUT -o $OUTPUT\.intervals

GenomeAnalysisTK -T IndelRealigner -R \
   /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/rawg0043_Gambusia_sexradiata_kelley.fasta \
  -I $INPUT -targetIntervals $OUTPUT\.intervals --consensusDeterminationModel USE_READS  -o $OUTPUT\_realigned.bam
