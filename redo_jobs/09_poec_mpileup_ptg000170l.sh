#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=09_poec_mpileup_ptg000170l
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=09_poec_mpileup_out/09_poec_mpileup_ptg000170l.out
#SBATCH --error=09_poec_mpileup_err/09_poec_mpileup_ptg000170l.err

module load miniconda3
conda activate bcftools_v1.16

cd /data/colibri/kelley_lab/bogan/RepAdapt/09_mpileup/poec/

CHROM="ptg000170l"

bcftools mpileup \
    -Ou \
    -f /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta \
    --bam-list /data/colibri/kelley_lab/bogan/RepAdapt/08_cnv/poec/08_list1_redo.txt \
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
