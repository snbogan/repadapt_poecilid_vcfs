#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=gam_bwa_map
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-40
#SBATCH --output=gam_bwa_map_out/out_%A_%a.out
#SBATCH --error=gam_bwa_map_err/err_%A_%a.err

# Move to working directory
cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/03_bwa_map/gam/

# Load required modules
module load bwa samtools

# Input and output lists
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list1.txt)  # Combined R1 fastq.gz
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list2.txt)  # Combined R2 fastq.gz
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list3.txt)  # Output file prefix (no extensions)

# Reference genome
REFGENOME=/hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/gam/rawg0043_Gambusia_sexradiata_kelley.fasta

# Output directory
OUTDIR=/hb/home/snbogan/RepAdapt/poecilid_vcfs/03_bwa_map/gam/bwa_output

# Alignment and processing
bwa mem -t 4 $REFGENOME $INPUT1 $INPUT2 > ${OUTDIR}/${OUTPUT}.sam

samtools view -Sb -q 10 ${OUTDIR}/${OUTPUT}.sam > ${OUTDIR}/${OUTPUT}.bam
rm ${OUTDIR}/${OUTPUT}.sam

samtools sort --threads 4 ${OUTDIR}/${OUTPUT}.bam > ${OUTDIR}/${OUTPUT}_sorted.bam
rm ${OUTDIR}/${OUTPUT}.bam

samtools index ${OUTDIR}/${OUTPUT}_sorted.bam

