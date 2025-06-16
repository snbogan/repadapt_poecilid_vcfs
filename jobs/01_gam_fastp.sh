#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --job-name=repadapt_gam_fastp
#SBATCH --time=0-12:00:00
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --output=repadapt_gam_fastp_out/out_%A_%a.out
#SBATCH --error=repadapt_gam_fastp_err/err_%A_%a.err
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=8G
#SBATCH --array=1-40

# Move to wd
cd /hb/home/snbogan/RepAdapt/peo/01_fastp/gam/

### THESE LISTS NEED TO FOLLOW THE SAME ORDER
INPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /hb/home/snbogan/RepAdapt/poecilid_vcfs/01_fastp/gam/list1.txt)  ### A list of your R1 fastq files
INPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /hb/home/snbogan/RepAdapt/poecilid_vcfs/01_fastp/gam/list2.txt)  ### A list of your R2 fastq files
OUTPUT1=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /hb/home/snbogan/RepAdapt/poecilid_vcfs/01_fastp/gam/list3.txt) ### A list of R1 output names -- just capture the meaningful part of the fastq names including R1 (remove the fq.gz or fq suffix)
OUTPUT2=$(sed -n "${SLURM_ARRAY_TASK_ID}p" /hb/home/snbogan/RepAdapt/poecilid_vcfs/01_fastp/gam/list4.txt) ### A list of R2 output names -- just capture the meaningful part of the fastq names including R2 (remove the fq.gz or fq suffix)

# Load modules
module load fastp

### Trimming --  for each sample pair of raw fastq reads or for each library, we produce a pair of trimmed output files.
### Remember to keep R1 and R2 in the output names created in lists 3 and 4 above
### This below uses 4 cores

fastp -w  4 -i $INPUT1 -I $INPUT2 -o $OUTPUT1\_trimmed.fastq.gz -O $OUTPUT2\_trimmed.fastq.gz
