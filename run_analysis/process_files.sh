#!/bin/bash          

while read line
do
#echo $line;
last=${line: -2}
append=_001.fastq

if [ "$last" = "R1" ]
then
   echo "Processing file R1"
gunzip $line$append.gz
mkdir $line
echo "Processing reads to split libraries"
split_libraries_fastq.py -o $line/ -i $line$append  --sample_id s1 -m test.txt  -q 19 --barcode_type 'not-barcoded'

elif [ "$last" = "R2" ]
then
    echo "Processing file R2"
gunzip $line$append.gz
mkdir $line
echo "Processing reads to split library"
split_libraries_fastq.py -o $line/ -i $line$append  --sample_id s1 -m test.txt  -q 19 --barcode_type 'not-barcoded' --rev_comp
else
    echo "Not Cool Beans"
fi

done < $1
