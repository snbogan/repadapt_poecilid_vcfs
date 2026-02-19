#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=07_ab_realign_indel
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=60G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-257
#SBATCH --output=07_ab_realign_indel_out/07_ab_realign_indel_%A_%a.out
#SBATCH --error=07_ab_realign_indel_err/07_ab_realign_indel_%A_%a.err

# Move to wd 1
cd /home/snbogan/repadapt/vcf/invert/07_realign_indel/abalone/

### Keep the lists below with the same order
INPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list1.txt) ### list of bam files with read groups (output of script 05)
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 07_list2.txt)  ### list of output names (just remove .bam suffix from input list)

module load miniconda3
conda activate samtools1.16.1

# Move to wd 2
cd /hb/home/snbogan/repadapt/vcf/invert/05_rg/abalone/

# Index rg bam files
samtools index $INPUT

conda deactivate
module purge

# Move to wd 1
cd /hb/home/snbogan/repadapt/vcf/invert/07_realign_indel/abalone/

### Here we generate a indel realigned bam file for each sample/library
module load java
module load miniconda3
conda activate gatk_v3.8

GenomeAnalysisTK -T RealignerTargetCreator \
 -R /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/GCA_023055435.1_xgHalRufe1.0.p_genomic.fna \
 -I $INPUT -o $OUTPUT\.intervals

GenomeAnalysisTK -T IndelRealigner -R \
  /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/GCA_023055435.1_xgHalRufe1.0.p_genomic.fna \
  -I $INPUT -targetIntervals $OUTPUT\.intervals --consensusDeterminationModel USE_READS  -o $OUTPUT\_realigned.bam
