#!/bin/bash
#SBATCH --account=pi-jkoc
#SBATCH --partition=lab-colibri
#SBATCH --qos=pi-jkoc
#SBATCH --time=0-12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=5G
#SBATCH --mail-user=snbogan@ucsc.edu
#SBATCH --mail-type=ALL
#SBATCH --job-name=gam_depth_table
#SBATCH --output=gam_depth_table.out
#SBATCH --error=gam_depth_table.err

##### THIS IS NOT A ARRAY; THIS IS RUN ONCE PER DATASET
##### this script needs to be run in the same directory where the final realigned bam files (output of 07_realign_indel.sh) as well as the depth statistics files for each sample (output of 08_cnv_2.sh) are located
##### you need to create list.txt which is a list of the root names of all realigned bam files -- created with the first find/sed command below by removing the suffix .bam and the initial two characters "./" from the realigned bam files names

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/07_realign_indel/gam/

find . -name "*realigned.bam" | sed 's/.bam//g' | sed 's/^..//g' > list.txt

echo -e "location\t$(cut -f2 list.txt | sort | uniq | paste -s -d '\t')" > depthheader.txt

# get a list of sample names
cut -f2 list.txt | sort | uniq > /hb/home/snbogan/RepAdapt/poecilid_vcfs/08_cnv/gam/samples.txt

cd /hb/home/snbogan/RepAdapt/poecilid_vcfs/08_cnv/gam/

### combine windowed depth analysis results
# get just the second (depth) column of each output file
while read samp; do cut -f2 ${samp}-windows.sorted.tsv > ${samp}-windows.sorted.depthcol ; done < samples.txt

# combine both columns of the first output file and add the second column of all other files
paste $(sed 's/^/.\//' samples.txt | sed 's/$/-windows.sorted.tsv/' | head -n 1) $(sed 's/^/.\//' samples.txt | sed 's/$/-windows.sorted.depthcol/' | tail -n +2) > ./combined-windows.temp

# add header
cat ./depthheader.txt ./combined-windows.temp > ./combined_windows.tsv

### combine gene depth analysis results
# get just the second (depth) column of each output file
while read samp; do cut -f2 ./${samp}-genes.sorted.tsv > ./${samp}-genes.sorted.depthcol ; done < ./samples.txt

# combine both columns of the first output file and add the second column of all other files
paste $(sed 's/^/.\//' ./samples.txt | sed 's/$/-genes.sorted.tsv/' | head -n 1) $(sed 's/^/.\//' ./samples.txt | sed 's/$/-genes.sorted.depthcol/' | tail -n +2) > ./combined-genes.temp

# add header
cat ./depthheader.txt ./combined-genes.temp > ./combined_genes.tsv

### make a table of whole-genome depths from samtools
while read samp; do echo -e $samp"\t"$(cat ./$samp-wg.txt); done < ./samples.txt > combined_wg.tsv


rm *temp
rm *depthcol
rm depthheader.txt
rm samples.txt
