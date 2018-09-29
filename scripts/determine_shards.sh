#!/bin/sh
determine_shards_from_bam()
{
    local bam parts step tag chr len pos end
    bam="$1"
    parts="$2"
    pos=$parts
    total=$(samtools view -H $bam |
        (while read tag chr len
        do
            [ $tag == '@SQ' ] || continue
            chr=$(expr "$chr" : 'SN:\(.*\)')
            len=$(expr "$len" : 'LN:\(.*\)')
            pos=$(($pos + $len))
        done; 
        echo $pos))
    step=$(( $total/$parts ))

    pos=1
    echo -n '["'
    samtools view -H $bam |
        while read tag chr len
        do
            [ $tag == '@SQ' ] || continue
            chr=$(expr "$chr" : 'SN:\(.*\)')
            len=$(expr "$len" : 'LN:\(.*\)')
            while [ $pos -le $len ]; do
                end=$(($pos + $step - 1))
                if [ $pos -lt 0 ]; then
                    start=1
                else
                    start=$pos
                fi

                if [ $end -gt $len ]; then
                    if [ $start -eq 1 ]; then
                        echo -n "$chr,"
                        else
                        echo -n "$chr:$start-$len,"
                    fi
                    pos=$(($pos-$len))
                    break
                else
                    echo -n "$chr:$start-$end",""
                    pos=$(($end + 1))
                fi
            done
        done
    echo 'NO_COOR"]'
}


determine_shards_from_fai()
{
    local bam step tag chr len pos end
    fai="$1"
    parts="$2"
    boundary_unit=10000
    pos=$parts
    total=$(cat $fai |
    (while read chr len UR
    do
        pos=$(($pos + $len))
    done; echo $pos))
    step=$((($total-1)/$parts+1 ))
    
    pos=1
    echo -n '["'
    cat $fai |
    while read chr len other
    do
        while [ $pos -le $len ]; do
            end=$(($pos + $step - 1))
            if [ $pos -lt 0 ]; then
                start=1
            else
                start=$pos
            fi
            if [ $end -le $len ]; then
                n=$(($((($end-1) / $boundary_unit))+1))
                end=$(($n * $boundary_unit))
            fi
            if [ $end -gt $len ]; then
                if [ $start -eq 1 ]; then
                    echo -n "$chr,"
                else
                    echo -n "$chr:$start-$len,"
                fi
                pos=$(($pos-$len))
                break
            else
                echo -n "$chr:$start-$end", ""
                pos=$(($end + 1))
            fi
        done
    done
    echo 'NO_COOR"]'
}

if [ $# -eq 2 ]; then
    filename=$(basename "$1")
    extension="${filename##*.}"
    if [ "$extension" = "fai" ]; then
        determine_shards_from_fai $1 $2
    elif [ "$extension" = "bam" ]; then
        determine_shards_from_bam $1 $2
    fi
else
    echo "usage $0 file shard_size"
fi
