#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --time=0-01:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name=gam_prepare_depth_files
#SBATCH --output=gam_prepare_depth_files.out
#SBATCH --error=gam_prepare_depth_files.err

module load bedtools
module load samtools

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/02_bwa_index/gam/

# make a genomefile for bedtools
awk '{print $1"\t"$2}' *.fai > genome.bed

# make a BED file of 5000 bp windows from FASTA index
awk -v w=5000 '{chr = $1; chr_len = $2;
    for (start = 0; start < chr_len; start += w) {
        end = ((start + w) < chr_len ? (start + w) : chr_len);
        print chr "\t" start "\t" end;
    }
}' *.fai > windows.bed

# now make location list from window bedfile and sort for join
awk -F "\t" '{print $1":"$2"-"$3}' windows.bed | sort -k1,1 > windows.list

# and a bed file of each gene
awk '$3 == "gene" {print $1"\t"$4"\t"$5}' *gff | uniq > genes.bed

# sort genes based on reference index
cut -f1 *.fai | while read chr; do awk -v chr=$chr '$1 == chr {print $0}' genes.bed | sort -k2,2n; done > genes.sorted.bed
mv genes.sorted.bed genes.bed

# now make location list from sorted gene bedfile and sort for join
awk -F "\t" '{print $1":"$2"-"$3}' genes.bed | sort -k1,1 > genes.list
