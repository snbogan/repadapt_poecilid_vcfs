#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_realign_indel
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=60G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-160
#SBATCH --output=poec_realign_indel_out/out_%A_%a.out
#SBATCH --error=poec_realign_indel_err/err_%A_%a.err

# Move to wd 1
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/07_realign_indel/poec/

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list1.txt) ### list of bam files with read groups (output of script 05)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list2_cleaned.txt)  ### list of output names (just remove .bam suffix from input list)

module load samtools

# Move to wd 2
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/05_rg/poec/

# Index rg bam files
samtools index $INPUT

# Move to wd 1
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/07_realign_indel/poec/

### Here we generate a indel realigned bam file for each sample/library
module load java
module load miniconda3
conda activate gatk_v3.8

GenomeAnalysisTK -T RealignerTargetCreator \
 -R /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta \ -I $INPUT -o $OUTPUT\.intervals

GenomeAnalysisTK -T IndelRealigner -R \
 /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta \
  -I $INPUT -targetIntervals $OUTPUT\.intervals --consensusDeterminationModel USE_READS  -o $OUTPUT\_realigned.bam
