#!/bin/bash
#SBATCH --job-name=liftoff
#SBATCH --time=4-00:00:00
#SBATCH --partition=windfall
#SBATCH --output=out/liftoff_%j.out # output file
#SBATCH --error=err/liftoff_%j.err # error file
#SBATCH --cpus-per-task=6
#SBATCH --mem=48GB
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=BEGIN,END,FAIL

module load miniconda3
conda activate liftoff

cd /data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam

liftoff -g GCF_019740435.1_SWU_Gaff_1.0_genomic.fna.gff \
-o rawg0043_Gambusia_sexradiata_kelley.gff -u rawg0043_Gambusia_sexradiata_kelley.unmapped.features.txt \
-dir rawg0043_Gambusia_sexradiata_kelley_liftoff -p 6 \
-polish -copies \
rawg0043_Gambusia_sexradiata_kelley.fasta GCF_019740435.1_SWU_Gaff_1.0_genomic.fna
