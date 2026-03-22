#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=10_ab_concat
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=03-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=10_ab_concat.out
#SBATCH --error=10_ab_concat.err

module load miniconda3
conda activate bcftools_v1.16

cd /home/snbogan/repadapt/vcf/invert/10_concat/abalone

### Concatenate all the chromsome vcfs produced in script 09. 
### list.txt is a list of the 14 (in this case) vcfs produced in script 09.
### Here we concatenate them in a single vcf

bcftools concat -f list.txt -Oz > ab.vcf.gz
tabix -p vcf ab.vcf.gz
