#!/bin/sh

fastq_index=$1
parts=$2

chunks=($SENTIEON_INSTALL_DIR/bin/sentieon fqidx query -i $fastq_index | cut -f1 -d' ')
chunk_per_job=`expr $((chunks-1)) / $parts + 1`
echo -n "["
for i in $(seq 0 $((parts-1))); do
    k_start=$(($i*$chunk_per_job))
    k_end=$(($k_start+$chunk_per_job))
    if [ $i -ne 0 ]; then
       echo -n ","
    fi  
    echo -n "\"$k_start-$k_end\""
done
echo "]"
