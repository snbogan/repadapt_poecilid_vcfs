#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=02_ab_bwa_index
#SBATCH --time=0-12:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=02_ab_bwa_index.out
#SBATCH --error=02_ab_bwa_indexx.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

### Here we just create the bwa index of the reference genome, needed for mapping
### Keep the output of this command in the same dir where you keep the reference genome fasta

module load miniconda3
conda activate bwa_v0.7.17

cd /hb/home/snbogan/repadapt/vcf/invert/genomes/abalone/

bwa index -a bwtsw rawg0133_Haliotis_rufescens_Bogan.fna
