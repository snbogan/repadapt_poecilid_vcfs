#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=gam_concat
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=02-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=gam_concat.out
#SBATCH --error=gam_concat.err

module load bcftools

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/10_concat/gam/

### Concatenate all the chromsome vcfs produced in script 09. 
### list.txt is a list of the 14 (in this case) vcfs produced in script 09.
### Here we concatenate them in a single vcf

bcftools concat -f list.txt -Oz > gam.vcf.gz
tabix -p vcf gam.vcf.gz
