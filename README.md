#Notes before running
To install qiime first clone two repositories
qiime-deploy and qiime-deploy-config from github 
eg:
git@github.com:qiime/qiime-deploy-conf.git

into your src directory
then specify the following to install qiime

python qiime-deploy.py $HOME/src/qiime/-f ../qiime-deploy-conf/qiime-1.8.0/qiime.conf

This will install qiime in $HOME/src/qiime- you may want somewhere different.

You then need to add this path to your .profile and reload your profile (source .profile)
The path will be something like this:

$HOME/src/qiime/qiime-1.8.0-release/bin

usearch-
you need to download usearch version 5.2.3.2 and put in your local binaries directory- either by symlink
or by renaming as usearch 


##This repository
There are two directories of scripts, one called run_analysis - this is for if you already have databases 
and another called database_modify, which is for custom database work


#######TO RUN AN ANALYSIS- the run_analysis directory

You need to either copy all the github (this repo) scripts and files to the directory from which you are 
doing the analysis, or you need to add the reposistory to your path. 


Ensure you have the text.txt in your directory and run the script from this library called 

process_files.sh short.txt 

The text file short.txt contains a list of the filenames upto the read number eg:

16SBIOFUM-1_S1_L001_R1
16SBIOFUM-1_S1_L001_R2


You can make this by looping through the list of files and clipping the end:
e.g.:

ls | while read i; do echo $i | sed -e "s/_001.fastq.gz//"; done > names.txt


YOu then need to run the script 

metagenomics_analysis.sh short.txt sh_refs_qiime_ver6_97_s_15.01.2014.fasta sh_taxonomy_qiime_ver6_97_s_15.01.2014.txt 

where you are giving paths to the list, the fasta part of the database and the taxonomy part of the database 

This will then do the analysis for you. 

Remember, use nohup and & as prefix and suffix respectively to kill the output from screen (no hangup) and put in the background. 
Alternatively use screen. 



#########MODIFY A DATABASE
First run the script, pointing out the path to your fasta file containing the sequences you are interested in. 
You will have to supply a number to start from- this should be calculated from the database you wish to add to. This means there will be non-overlapping numbers in the sequence accessions. If you want to use your own database, then you should leave this blank and it will automatically start at 00000

The difference between v1 and v2 is that v2 is for consensus seqs- v1 is for annotation of anything in genbank that you have a sequence for.

database_maker_v2.pl PATHANDNAMEOFSEQ NUMBERTOSTART qiime_file.txt fasta_file.txt 

then simply cat the two files together to the existing database, if needed, assuming you've sorted the numbers out (script still to develop)


The number to start from can be found like so:

awk 'NR%2 ' sh_refs_qiime_ver6_99_s_15.01.2014.fasta | cut -d'.' -f1 |  sed 's/[^0-9]*//g' |sort -r| head -1


##############
Running Xiangming's analysis

nohup /home/harrir/git_master/metagenomics/database_modify/database_maker_v2.pl ./consensus/consensus.fasta 459253 custom_number.fa custom_qiime_number.txt &

cp ./database/custom_qiime_number.txt ./working_databases/.
cp ./database/custom_number.fa ./working_databases/.
cat sh_refs_qiime_ver6_99_s_15.01.2014.fasta custom_number.fa >custom_numbered.fasta
cat sh_taxonomy_qiime_ver6_99_s_15.01.2014.txt custom_qiime_number.txt >custom_taxonomy_numbered.txt


nohup /home/harrir/git_master/metagenomics/run_analysis/process_files.sh 18Snames.txt &
nohup  /home/harrir/git_master/metagenomics/run_analysis/metagenomics_analysis.sh 18Snames.txt ../working_databases/custom_taxonomy_numbered.txt ../working_databases/custom_numbered.fasta  &
 nohup /home/harrir/git_master/metagenomics/run_analysis/process_files.sh samples_2.txt &
nohup  /home/harrir/git_master/metagenomics/run_analysis/metagenomics_analysis.sh samples_2.txt ../working_databases/custom_taxonomy_numbered.txt ../working_databases/custom_numbered.fasta  &

