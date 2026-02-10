#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=03a_ab_bwa_map
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=1-257
#SBATCH --output=03a_ab_bwa_map_out/out_%A_%a.out
#SBATCH --error=03a_ab_bwa_map_err/err_%A_%a.err

# Load packages (samtools v1.16.1 is installed in bwa)
module load miniconda3
conda activate bwa_v0.7.17

# Move to working directory
cd /hb/home/snbogan/repadapt/vcf/invert/03_bwa_map/abalone

# Input and output lists
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list1.txt)  # Combined R1 fastq.gz
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list2.txt)  # Combined R2 fastq.gz
OUTPUT=$(sed -n "${SLURM_ARRAY_TASK_ID}p" 03_list3.txt)  # Output file prefix (no extensions)

# Reference genome
REFGENOME=/hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/GCA_023055435.1_xgHalRufe1.0.p_genomic.fna

# Output directory
OUTDIR=/hb/home/snbogan/repadapt/vcf/invert/03_bwa_map/abalone/bwa_output

# Alignment and processing
bwa mem -t 4 $REFGENOME $INPUT1 $INPUT2 > ${OUTDIR}/${OUTPUT}.sam

samtools view -Sb -q 10 ${OUTDIR}/${OUTPUT}.sam > ${OUTDIR}/${OUTPUT}.bam
rm ${OUTDIR}/${OUTPUT}.sam

samtools sort --threads 4 ${OUTDIR}/${OUTPUT}.bam > ${OUTDIR}/${OUTPUT}_sorted.bam
rm ${OUTDIR}/${OUTPUT}.bam

samtools index ${OUTDIR}/${OUTPUT}_sorted.bam

