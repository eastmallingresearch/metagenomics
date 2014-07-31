#!/bin/bash

while read line
do
#echo $line;
last=${line: -2}
r1=R1
r2=R2

if [ "$last" = "R1" ]
then
   echo "Processing file R1"
cd $line   
pick_de_novo_otus.py -i seqs.fna -o pick_otus.out -v
assign_taxonomy.py  -i pick_otus.out/rep_set/seqs_rep_set.fasta -m rtax --single_ok --amplicon_id_regex='(\S+)\s+(\S+)' --header_id_regex='\S+\s+(\S+)'   --read_1_seqs_fp seqs.fna --read_2_seqs_fp $HOME/projects/xiangming_metagenomics/feb_2014/$line$R2/seqs.fna -r  $HOME/projects/xiangming_metagenomics/feb_2014/database/sh_refs_qiime_ver6_97_s_15.01.2014.fasta  -t  $HOME/projects/xiangming_metagenomics/run2/database/sh_taxonomy_qiime_ver6_97_s_15.01.2014.txt -v
cd ..

else
    echo "Read 2- skipping"
fi

done < $1
~             
