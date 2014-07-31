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

#######TO RUN AN ANALYSIS

You need to either copy all the github (this repo) scripts and files to the directory from which you are 
doing the analysis, or you need to add the reposistory to your path. 


Ensure you have the text.txt in your directory and run the script from this library called 

process_files.sh short.txt 

The text file short.txt contains a list of the filenames upto the read number eg:

16SBIOFUM-1_S1_L001_R1
16SBIOFUM-1_S1_L001_R2

YOu then need to run the script 

metagenomics_analysis.sh short.txt 

This will then do the analysis for you. 



