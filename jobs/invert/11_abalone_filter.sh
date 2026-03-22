#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=11_ab_filter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=11_ab_filter.out
#SBATCH --error=11_ab_filter.err

module load miniconda3
conda activate bcftools_v1.16 # has tabix/0.2.6 installed

########### Only filtering the VCF to exclude sites with QUAL < 30 and invariant ALT/ALT sites (AC = AN) ###########

cd /hb/home/snbogan/repadapt/vcf/invert/10_concat/abalone/

bcftools filter -e 'AC=AN || MQ < 30' ab.vcf.gz -Ov > ab_filtered.vcf

### As an alternative to the bcftools command above, vcftools can also be used to filter by QUAL:
### vcftools --gzvcf bplaty.vcf.gz --minQ 30 --recode --recode-INFO-all --stdout > bplaty_filtered.vcf

bgzip ab_filtered.vcf
tabix -p vcf ab_filtered.vcf.gz
