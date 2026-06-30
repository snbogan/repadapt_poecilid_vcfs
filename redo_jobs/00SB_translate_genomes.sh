#!/bin/bash
#SBATCH --partition=windfall
#SBATCH --job-name=00SB_prot_seq
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=16G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --array=0-1
#SBATCH --output=00SB_prot_seq_out/out_%A_%a.out
#SBATCH --error=00SB_prot_seq_err/err_%A_%a.err

module load miniconda3
conda activate gffread

cd /home/snbogan/repadapt/prot_seq

# Input files
GENOMES=(
"/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/rawg0043_Gambusia_sexradiata_kelley.fasta"
"/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.fasta"
)

GFFS=(
"/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/gam/rawg0043_Gambusia_sexradiata_kelley.gff"
"/data/colibri/kelley_lab/bogan/RepAdapt/02_bwa_index/poec/rawg0041_Poecilia_mexicana_kelley.gff"
)

OUTS=(
"rawg0043_Gambusia_sexradiata_kelley.faa"
"rawg0041_Poecilia_mexicana_kelley.faa"
)

i=$SLURM_ARRAY_TASK_ID

echo "Processing ${OUTS[$i]}"

gffread \
    "${GFFS[$i]}" \
    -g "${GENOMES[$i]}" \
    -y "${OUTS[$i]}" \
    -S

echo "Finished ${OUTS[$i]}"
