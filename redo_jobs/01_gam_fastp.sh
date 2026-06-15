#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=01_gam_fastp_pt1
#SBATCH --time=3-00:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=01_gam_fastp_pt1_out/out_%A_%a.out
#SBATCH --error=01_gam_fastp_pt1_err/err_%A_%a.err
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=30G
#SBATCH --array=1-40

# Move to working directory
cd /data/colibri/kelley_lab/bogan/RepAdapt/01_fastp/gam/

# Corresponding files for each sample
R1_FC1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list1.txt)
R2_FC1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list2.txt)

R1_FC2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list5.txt)
R2_FC2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list6.txt)

OUTPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list7.txt)
OUTPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" list8.txt)

# Temporary combined files
COMBINED_R1=${OUTPUT1}_combined_R1.fastq.gz
COMBINED_R2=${OUTPUT2}_combined_R2.fastq.gz

# Repaired files
REPAIRED_R1=${OUTPUT1}_repaired_R1.fastq.gz
REPAIRED_R2=${OUTPUT2}_repaired_R2.fastq.gz
SINGLETONS=${OUTPUT1}_singletons.fastq.gz

# Combine flow cells
cat "$R1_FC1" "$R1_FC2" > "$COMBINED_R1"
cat "$R2_FC1" "$R2_FC2" > "$COMBINED_R2"

# Repair read pairing
module load miniconda3
conda activate bbmap

repair.sh \
    in1="$COMBINED_R1" \
    in2="$COMBINED_R2" \
    out1="$REPAIRED_R1" \
    out2="$REPAIRED_R2" \
    outs="$SINGLETONS"

# Run fastp on repaired reads
conda deactivate
conda activate fastp_v0.20.1

fastp -w 4 \
    -i "$REPAIRED_R1" \
    -I "$REPAIRED_R2" \
    -o "${OUTPUT1}_R1_trimmed.fastq.gz" \
    -O "${OUTPUT2}_R2_trimmed.fastq.gz"
