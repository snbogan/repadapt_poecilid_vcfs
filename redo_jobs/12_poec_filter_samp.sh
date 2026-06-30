#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=12_poec_filter_samp
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=12_poec_filter_samp.out
#SBATCH --error=12_poec_filter_samp.err

module load miniconda3
conda activate bcftools_v1.16 # has tabix/0.2.6 installed

cd /data/colibri/kelley_lab/bogan/RepAdapt/10_concat/poec/

bcftools view \
    -s ^MX13-001_S89_L004,MX13-003_S90_L004 \
    -Oz \
    -o /home/snbogan/repadapt/vcf/fish_outputs/rawg0041_Poecilia_mexicana_kelley.filtered.vcf.gz \
    rawg0041_Poecilia_mexicana_kelley.vcf.gz
    
tabix -p vcf /home/snbogan/repadapt/vcf/fish_outputs/rawg0041_Poecilia_mexicana_kelley.filtered.vcf.gz

