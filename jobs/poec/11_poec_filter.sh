#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_filter
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=poec_filter.out
#SBATCH --error=poec_filter.err

module load vcftools bcftools

########### Only filtering the VCF to exclude sites with QUAL < 30 and invariant ALT/ALT sites (AC = AN) ###########

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/10_concat/poec/

bcftools filter -e 'AC=AN || MQ < 30' poec.vcf.gz -Ov > poec_filtered.vcf

### As an alternative to the bcftools command above, vcftools can also be used to filter by QUAL:
### vcftools --gzvcf bplaty.vcf.gz --minQ 30 --recode --recode-INFO-all --stdout > bplaty_filtered.vcf

bgzip poec_filtered.vcf
tabix -p vcf poec_filtered.vcf.gz
