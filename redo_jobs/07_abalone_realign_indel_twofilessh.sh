#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=07_ab_realign_indel_twofiles
#SBATCH --time=5-00:00:00
#SBATCH --mem-per-cpu=60G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-2
#SBATCH --output=07_ab_realign_indel_twofiles_out/07_ab_realign_indel_two_files%A_%a.out
#SBATCH --error=07_ab_realign_indel_twofiles_err/07_ab_realign_indel_twofiles%A_%a.err

# Move to wd 1
cd /home/snbogan/repadapt/vcf/invert/07_realign_indel/abalone/

# Get the line numbers corresponding to the two desired samples
LINE_NUMS=($(grep -nE 'SRR20993869|SRR20994022' 07_list1.txt | cut -d: -f1))

# Select the appropriate line for this array task
LINE=${LINE_NUMS[$((SLURM_ARRAY_TASK_ID-1))]}

INPUT=$(sed -n "${LINE}p" 07_list1.txt)
OUTPUT=$(sed -n "${LINE}p" 07_list2.txt)

echo "Processing:"
echo "  INPUT  = $INPUT"
echo "  OUTPUT = $OUTPUT"

module load miniconda3
conda activate samtools1.16.1

# Move to wd 2
cd /hb/home/snbogan/repadapt/vcf/invert/05_rg/abalone/

# Index rg bam files
samtools index "$INPUT"

conda deactivate
module purge

# Move to wd 1
cd /hb/home/snbogan/repadapt/vcf/invert/07_realign_indel/abalone/

# Here we generate an indel realigned bam file for each sample/library
module load java
module load miniconda3
conda activate gatk_v3.8

GenomeAnalysisTK -T RealignerTargetCreator \
  -R /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/rawg0133_Haliotis_rufescens_Bogan.fna \
  -I "$INPUT" \
  -o "${OUTPUT}.intervals"

GenomeAnalysisTK -T IndelRealigner \
  -R /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/rawg0133_Haliotis_rufescens_Bogan.fna \
  -I "$INPUT" \
  -targetIntervals "${OUTPUT}.intervals" \
  --consensusDeterminationModel USE_READS \
  -o "${OUTPUT}_realigned.bam"
