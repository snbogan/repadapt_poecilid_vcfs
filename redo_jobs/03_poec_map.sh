#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_bwa_map
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-160
#SBATCH --output=poec_bwa_map_out/out_%A_%a.out
#SBATCH --error=poec_bwa_map_err/err_%A_%a.err

# Move to working directory
cd /data/colibri/kelley_lab/bogan/RepAdapt/03_bwa_map/poec/

# Load packages (samtools v1.16.1 is installed in bwa)
module load miniconda3
conda activate bwa_v0.7.17

# Input and output lists
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list1_redo.txt)  # Combined R1 fastq.gz
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list2_redo.txt)  # Combined R2 fastq.gz
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list3_redo.txt)  # Output file prefix (no extensions)

# Reference genome
REFGENOME=/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta

# Output directory
OUTDIR=/data/colibri/kelley_lab/bogan/RepAdapt/03_bwa_map/poec/bwa_output

# Alignment and processing
bwa mem -t 4 $REFGENOME $INPUT1 $INPUT2 > ${OUTDIR}/${OUTPUT}.sam

samtools view -Sb -q 10 ${OUTDIR}/${OUTPUT}.sam > ${OUTDIR}/${OUTPUT}.bam
rm ${OUTDIR}/${OUTPUT}.sam

samtools sort --threads 4 ${OUTDIR}/${OUTPUT}.bam > ${OUTDIR}/${OUTPUT}_sorted.bam
rm ${OUTDIR}/${OUTPUT}.bam

samtools index ${OUTDIR}/${OUTPUT}_sorted.bam
