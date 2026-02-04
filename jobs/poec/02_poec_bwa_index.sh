#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=poec_bwa_index
#SBATCH --time=0-12:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=poec_bwa_index.out
#SBATCH --error=poec_bwa_index.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G

### Here we just create the bwa index of the reference genome, needed for mapping
### Keep the output of this command in the same dir where you keep the reference genome fasta

module load bwa

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/poec/

bwa index -a bwtsw /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta
