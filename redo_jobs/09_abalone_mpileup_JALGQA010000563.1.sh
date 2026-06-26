#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=09_ab_mpileup_JALGQA010000563
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=09_ab_mpileup_out/09_ab_mpileup_JALGQA010000563.out
#SBATCH --error=09_ab_mpileup_err/09_ab_mpileup_JALGQA010000563.err

module load miniconda3
conda activate bcftools_v1.16

cd /home/snbogan/repadapt/vcf/invert/09_mpileup/abalone

CHROM="JALGQA010000563.1"

bcftools mpileup \
    -Ou \
    -f /home/snbogan/repadapt/vcf/invert/genomes/abalone/rawg0133_Haliotis_rufescens_Bogan.fna \
    --bam-list /home/snbogan/repadapt/vcf/invert/08_cnv/abalone/08_list1.txt \
    -q 5 \
    -r ${CHROM} \
    -I \
    -a FMT/AD,FMT/DP | \
bcftools call \
    -S ploidymap.txt \
    -G - \
    -f GQ \
    -mv \
    -Ov > ${CHROM}.vcf
