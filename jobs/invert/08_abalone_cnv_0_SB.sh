#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --time=7-00:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name=08_ab_liftover
#SBATCH --output=08_ab_liftover.out
#SBATCH --error=08_ab_liftover.err

cd /home/snbogan/repadapt/vcf/invert/genomes/abalone/

# Load modules if needed
module load minimap2
module load miniconda3
conda activate liftoff

# INPUT FILES
GCF_GENOME="GCF_023055435.1_xgHalRufe1.0.p_genomic.fna"
GCA_GENOME="GCA_023055435.1_xgHalRufe1.0.p_genomic.fna"
GCF_GFF="GCF_023055435.1.gff"

# OUTPUT
OUT_GFF="GCA_liftover_annotation.gff"
UNMAPPED="unmapped_features.txt"

echo "Starting Liftoff annotation transfer..."

liftoff \
    -g $GCF_GFF \
    -o $OUT_GFF \
    -u $UNMAPPED \
    -p $SLURM_CPUS_PER_TASK \
    $GCA_GENOME \
    $GCF_GENOME

echo "Liftover complete."
