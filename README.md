# Introduction

This document describes the integration of Sentieon software with CWL and Toil. This integration enables to easily run CWL-defined Sentieon pipelines on a variety of HPC and cloud environments, either on a single node or distributed onto multiple nodes for rapid turnaround processing. Please see Sentieon [Distribution Application Note](https://s3.amazonaws.com/sentieon-release/documentation/app_notes/App+note+-+Distributed+mode.pdf) on distribution mode for more information on that topic.

# Introduction to CWL and Toil

CWL, also known as Common Workflow Language, is a specification for describing analysis workflows and tools. The objective of CWL standards is to make analysis workflows portable and scalable on a variety of hardware and software environments. CWL enables application developers to focus on the pipeline development without having to worry about deployment details or distribution implementation. For more information about CWL, please refer to its [website](https://www.commonwl.org/).

Toil is a cross-platform pipeline management system and execution engine that implements the CWL standards. Toil enables executing pipelines defined in CWL on different job management systems. It is written in Python. Toil supports a number of scheduler systems, including Grid Engine, Slurm, Torque and LSF as well as workflow execution on public clouds including Amazon Web Services, Google Cloud, and Microsoft's Azure. For more details about Toil, please refer to its [website](http://toil.ucsc-cgl.org/).

Sentieon has developed a set of reference pipelines following CWL specification. Users can modify these pipelines to fit their needs for deployment in different environments.

Both CWL and Toil are under rapid development, and Sentieon is an active contributor to both open source projects. As CWL and Toil develop, Sentieon will continue to improve these templates to make them more user, and deployment-friendly. We welcome users' comment and feedback.

# System requirements

To run the CWL pipelines provided by Sentieon, the following software is required:

1.  Python 2.7 or above

2.  Node.js

3.  Toil-supported scheduler, for instance: Grid Engine, Slurm, Torque and LSF. In this App note, we will use LSF as an example (IBM Spectrum LSF Suite Community Edition 10.1. See IBM's [LSF website](https://www.ibm.com/support/knowledgecenter/en/SSWRJV_10.1.0/lsf_offering/lsfce10.1_quick_start.html) for more details)

4.  Cwltoil with versions and installation process below

To install cwltoil, first, clone the Sentieon's cwltoil repository from
github, and install the python library source:

    git clone https://github.com/liuxf09/toil.git
    git checkout tags/sentieon-toil-20180522
    cd toil
    pip install .

Then install cwltool python library:

    pip install cwltool

You should get cwltoil version as shown below:

    cwltoil --version
    DEBUG:rdflib:RDFLib Version: 4.2.2

You will also need the CWL template package provided by Sentieon. The package contains templates that define Sentieon algorithm modules and typical pipelines with commonly used settings.

Checkout this github repository:

    git clone https://github.com/Sentieon/Sentieon-cwl.git

There are three sub-directories:

-   *algo*: CWL definitions of all Sentieon algorithm modules and corresponding example input YAML files.
-   *stage*: CWL definitions of typical stages as building blocks for commonly used pipelines. An example is deduplication stage. This stage requires using two algo modules: LocusCollector and Dedup.
-   *pipeline*: CWL definitions of commonly used pipelines and corresponding example input YAML files.

# Prepare and run CWL pipeline

## YAML file

In typical CWL workflows, the CWL file defines the general pipeline, while a YAML file defines the input arguments of the pipeline. In the case of Sentieon's DNAseq germline variant calling pipeline from BAM to VCF, YAML defines the following:

-   Input BAM file
-   Reference file
-   Interval file or bed file, if necessary
-   dbSNP VCF
-   Known sites VCFs for indel realignment and BQSR
-   Intermediate output file names
-   Number of threads
-   Shards, which define how the whole reference is cut into small segments for distribution

Below is an example YAML file:

    reference: /path/to/ucsc.hg19.fasta
    input_bam:
      - sorted.bam
    realign_known_sites:
      - /path/to/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
      - /path/to/dbsnp_135.hg19.vcf.gz
    bqsr_known_sites:
      - /path/to/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
      - /path/to/dbsnp_135.hg19.vcf.gz
    dbsnp: /path/to/dbsnp_135.hg19.vcf.gz
    qcal_output_file: recal_table-pipeline.txt
    dedup_output_bam: deduped-pipeline.bam
    dedup_metrics_output_file: dedup-metrics.txt
    realign_output_bam: realigned-pipeline.bam
    output_file: output_hc.vcf.gz
    interval: interval.txt
    shard: ["chr1", "chr2", "chr3"]
    threads: 16

## Test-run a simple CWL pipeline

You should first test the initial CWL installation and integration with your chosen scheduler. You can follow the instructions below to execute a simple single-stage (algorithm Readwriter) CWL pipeline.

You will find a directory called cwl with a number of cwl and yaml files. For this test run, we will use `rw.cwl` and `rw.yaml`.

To get started, the user will need prepare a set of directories:

-   *Job store*: a centralized directory for all the temporary files for the workflow. Toil will initiate the job by copying all the necessary files to this location. The user will only need to create the parent directory for the job store. The job store must be accessible by all potential job nodes. Toil will create this directory if it is not present. After the job is complete, the job store directory will be cleared.
-   *Working directory*: Absolute path to the directory where temporary files generated during the workflow will be placed. The working directory can be in the local storage of the node. The user needs to create this directory before starting the job.
-   *Output directory*: Absolute path to the directory where the output of each stage and the final output will be stored. The user needs to create this directory before starting the job.

After creating the above directories, copy the rw.yaml to your own job directory, and modify the reference and input bam file path. Example of the `rw.yaml` is shown below.

    reference: /path/to/references/hg19/ucsc.hg19.fasta
    input_bam:
      - /path/to/jobdir/cwl/sorted.bam
    output_file: out.bam
    threads: 8

Then, the user needs to prepare Sentieon-specific environment variables:

-   Add `SENTIEON_INSTALL_DIR/bin` to `PATH`
-   Make sure `SENTIEON_LICENSE` is properly set
-   Set `SENTIEON_TMPDIR` to a fast local disk drive, instead of in a NFS to reduce IO.

Start the job with following command:

    workDIR=/path/to/workDir
    jobStore=/path/to/jobStore
    outDIR=/path/to/outDir
    templateDir=/path/to/Sentieon_CWL_TEMPLATE
    TMPDIR=$workDIR cwltoil --preserve-environment SENTIEON_LICENSE PATH SENTIEON_TMPDIR --workDir $workDIR --outdir $workDIR --batchSystem=lsf --jobStore file:$jobStore --logDebug --logFile run.log $templateDir/rw.cwl rw.yaml

Some additional comments:

-   Here we use LSF as the batch system. Simply set the option `--batchSystem` to use other batching systems. Please refer to the Toil manual for more details.

-   `--logDebug` defines the log level to DEBUG, and `--logFile` specifies a file path to write the logging output to.

After the job is finished successfully, you should be able to see `out.bam` in the output directory, as defined in the job setup `--outDir`. This shows the Toil setup is working as expected.

## Running distributed CWL pipeline

Running a distributed Sentieon CWL pipeline requires defining how the jobs are divided up among different nodes. Sentieon software natively supports sharded mode, where small regions of the genome, called shards, are processed in parallel. This allows computational work to be distributed across multiple servers or compute nodes. The shards are predefined in the yaml file. Without the shard option, only a single node is used as in the above example of `rw.yaml`.

Shards can be defined as below:

-   Chromosome name only, eg. chr1, chr2, etc.
-   Chromosome name and locus range, eg., chr1:1-1234556
-   A combination of above separated by comma, eg., chrM,chr1:1-123456,...

In the YAML file, the shard option defines an array of shards, below is an example:

    shard: [
    "1:1-50000000",
    "1:50000001-100000000",
    "1:100000001-150000000",
    "1:150000001-200000000",
    "1:200000001-249250621,2:1-749379",
    "2:749380-50749379",
    "2:50749380-100749379",
    "2:100749380-150749379",
    "2:150749380-200749379",
    "2:200749380-243199373,3:1-7550006",
    "3:7550007-57550006",
    "3:57550007-107550006",
    "3:107550007-157550006",
    "3:157550007-198022430,4:1-9527576",
    "4:9527577-59527576",
    "4:59527577-109527576",
    "4:109527577-159527576",
    ...
    ]

Below is a shell script to divide the whole genome into uniform shards. The  "NO_COOR" shard processes unmapped reads.

    PARTS=5 # shard size in base pair
    BAM=input.bam
    determine_shards_from_bam()
    {
        local bam parts step tag chr len pos end
        bam="$1"
        parts="$2"
        pos=$parts
        total=$($samtools view -H $bam |
            (while read tag chr len
            do
                [ $tag == '@SQ' ] || continue
                chr=$(expr "$chr" : 'SN:(.*)')
                len=$(expr "$len" : 'LN:(.*)')
                pos=$(($pos + $len))
            done; 
            echo $pos))
        step=$(( $total/$parts ))

        pos=1
        echo -n '["'
        $samtools view -H $bam |
            while read tag chr len
            do
                [ $tag == '@SQ' ] || continue
                chr=$(expr "$chr" : 'SN:(.*)')
                len=$(expr "$len" : 'LN:(.*)')
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
        echo "NO_COOR"]"
    }

    determine_shards_from_bam $BAM $PARTS > shards.txt

The user can use the above shell script to generate the set of shards for distributed jobs, completing the yaml file. With the yaml file updated, you can run the pipeline as in the above simple example.

## Test run a simple distribution CWL pipeline

Similar to `rw.cwl` for single-node CWL pipeline testing, Sentieon also provides `rw-distr.cwl` for distribution test-run.

Copy the `rw-distr.yaml` to a local directory, modify the input parameters of the file. Please note that the only difference between `rw.yaml` and `rw-distr.yaml` is the shard option.

    Reference: /path/to/references/hg19/ucsc.hg19.fasta
    input_bam:
      - /path/to/jobdir/cwl/sorted.bam
    output_file: out.bam
    shard: ["chr1", "chr2", "chr3"]
    threads: 8

Prepare the necessary directories as explained in the single-node test-run example, then run the pipeline as below:

    workDIR=/path/to/workDir
    jobStore=/path/to/jobStore
    outDIR=/path/to/outDir
    templateDir=/path/to/Sentieon_CWL_TEMPLATE

    TMPDIR=$workDIR cwltoil --preserve-environment SENTIEON_LICENSE PATH SENTIEON_TMPDIR --workDir $workDIR --outdir $workDIR --batchSystem=lsf --jobStore file:$jobStore --logDebug --logFile run.log $templateDir/rw-distr.cwl rw-distr.yaml

Please note that Sentieon can achieve the best performance by utilizing all available virtual cores. The scheduler needs to properly interpret the CPU resource request as virtual cores, instead of physical cores.

## Run distribution pipeline starting from Fastq to VCF

Running distribution pipeline from fastq requires a few extra steps to ensure identical result as running on a single server.

### Create index file for fastq files

Run the following command to create fastq file index:
    
    sentieon fqidx -K chunk_size -o fastq_index sample1_1.fq.gz sample1_2.fq.gz

where:

-   `-K chunk_size`: Defines the chunk size in bases. Same meaning as chunk size in bwa-mem. Using fixed chunk size makes sure consistent result. Example: -K 10000000.
-   `-o fastq_index`: Defines the output index file name.
-   `sample1_1.fq.gz` and `sample1_2.fq.gz`: input pair-ended fastq files.

Please refer to Sentieon's [App note - Distributed mode](https://s3.amazonaws.com/sentieon-release/documentation/app_notes/App+note+-+Distributed+mode.pdf) for more details of the `fqidx`.

Then query for the number of chunks in the index file by running the following command:

    sentieon fqidx query -i fastq_index

For example, you get the following output:

    1119 10000000 2 0

The four numbers refer to the following, respectively:

-   Total number of chunks
-   Chunk size
-   Number of input fastq files
-   Whether an interleaved fastq file is used

### Prepare YAML file

Below is an example of the `pipeline-fastq2vcf-distr.yaml` file.

    input_reads:
      - /data/NA11932_1000G_Exome_ERR034544_1.fastq.gz
      - /data/NA11932_1000G_Exome_ERR034544_2.fastq.gz

    input_reads_index_file: /data/NA11932_1000G_Exome_ERR034544.fq.idx
    reference: /path/to/references/hg19/ucsc.hg19.fasta

    realign_known_sites:
      - /path/to/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
      - /path/to/dbsnp_138.hg19.vcf.gz

    bqsr_known_sites:
      - /path/to/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
      - /path/to/dbsnp_138.hg19.vcf.gz

    dbsnp: /path/to/dbsnp_138.hg19.vcf.gz

    sort_output_bam: sorted-pipeline.bam
    qcal_output_file: recal_table-pipeline.txt
    dedup_output_bam: deduped-pipeline.bam
    dedup_metrics_output_file: dedup-metrics.txt
    output_file: output_hc.vcf.gz

    shard: ["chrM,chr1,chr2,chr3,chr4,chr5:1-165000000", \
            "chr5:165000001-180915260,chr6,chr7,chr8,chr9,chr10,chr11,chr12,chr13:1-8000000",\
            "chr13:8000001-115169878,chr14,chr15,chr16,chr17,chr18,chr19,chr20,chr21,chr22,chrX,chrY,chr1_gl000191_random,chr1_gl000192_random,chr4_ctg9_hap1,chr4_gl000193_random,chr4_gl000194_random,chr6_apd_hap1,chr6_cox_hap2,chr6_dbb_hap3,chr6_mann_hap4,chr6_mcf_hap5,chr6_qbl_hap6,chr6_ssto_hap7,chr7_gl000195_random,chr8_gl000196_random,chr8_gl000197_random,chr9_gl000198_random,chr9_gl000199_random,chr9_gl000200_random,chr9_gl000201_random,chr11_gl000202_random,chr17_ctg5_hap1,chr17_gl000203_random,chr17_gl000204_random,chr17_gl000205_random,chr17_gl000206_random,chr18_gl000207_random,chr19_gl000208_random,chr19_gl000209_random,chr21_gl000210_random,chrUn_gl000211,chrUn_gl000212,chrUn_gl000213,chrUn_gl000214,chrUn_gl000215,chrUn_gl000216,chrUn_gl000217,chrUn_gl000218,chrUn_gl000219,chrUn_gl000220,chrUn_gl000221,chrUn_gl000222,chrUn_gl000223,chrUn_gl000224,chrUn_gl000225,chrUn_gl000226,chrUn_gl000227,chrUn_gl000228,chrUn_gl000229,chrUn_gl000230,chrUn_gl000231,chrUn_gl000232,chrUn_gl000233,chrUn_gl000234,chrUn_gl000235,chrUn_gl000236,chrUn_gl000237,chrUn_gl000238,chrUn_gl000239,chrUn_gl000240,chrUn_gl000241,chrUn_gl000242,chrUn_gl000243,chrUn_gl000244,chrUn_gl000245,chrUn_gl000246,chrUn_gl000247,chrUn_gl000248,chrUn_gl000249,NO_COOR"]

    extract_chunks: ["0-373", "373-746", "746-1119"]
    chunk_size: 10000000
    readgroup: "group2"
    platform: "ILLUMINA"
    sample: "sample"
    library: "library"
    mark_secondary: true
    threads: 8

`extract_chunk` field defines how bwa stage is distributed. Using the following script to find out the exact range for distribution:

    chunks=1119 # the first number from fqidx query command
    parts=3 # number of distribution nodes
    chunk_per_job=`expr $((chunks-1)) / $parts + 1`
    for i in $(seq 0 $((parts-1))); do
        k_start=$(($i*$chunk_per_job))
        k_end=$(($k_start+$chunk_per_job))
        echo "$k_start-$k_end"
    done

In this case, with 1119 chunks distributed into 3 parts, the above script will give the following output. Enter these chunk ranges into the extract_chunk field of the yaml file.

    0-373
    373-746
    746-1119

Enter the shards generated from the fai file into shard field, using the following script:

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
            #[ $tag == '@SQ' ] || continue
            #chr=$(expr "$chr" : 'SN:(.*)')
            #len=$(expr "$len" : 'LN:(.*)')
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

With these preparation, user can run the cwltoil pipeline with the yaml input file and get the same result as in the single server.

# Specifying the path of input/output data files in YAML for Sentieon pipelines


Sentieon CWL pipelines support specifying the path of input data files either as a string or file. Below is an example:

    # Specifying path as a string
    reference: /path/to/references/hg19/ucsc.hg19.fasta
    # Specifying path as an array of string
    realign_known_sites:
      - /path/to/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
      - /path/to/dbsnp_138.hg19.vcf.gz
    # Specifying path as an array of File
    input_reads:
      - class: File
        path: NA11932_1000G_Exome_ERR034544_1.fastq.gz
      - class: File
        path: NA11932_1000G_Exome_ERR034544_2.fastq.gz

    # Speficying path as File
    input_reads_index_file:
      - class: File
        path: NA11932_1000G_Exome_ERR034544.fq.idx

    # Only specify the output file name as a string for output data files. Absolute path is not accepted.
    output_bam: output.bam

Sentieon recommends the following for best performance and compatibility:

-   When specifying the file path as a string, use *only* absolute path that can be used on *all* computing nodes.
-   For input files that will be used repeatedly throughout the pipeline, like reference, known sites, interval files, etc. use string representation so that the files are not copied to local working directory for every stage of the pipeline.
-   When specifying the file path as a file, one can either use absolute or relative path. However, when relative file path is used, the file is assumed to be in the same directory of the YAML file.
-   Put workDir, outDir and jobStore on the same device so that either symbolic link or hard link will be created for stage input/output to reduce file IO operation. Set `SENTIEON_TMPDIR` environment variable to a local scratch directory for temporary files of each stage and pass it to CWLtoil with `--preserve-environment` argument.
-   User can only specify the file name for output file. All output files will be saved at `outDir`, and user cannot dictate where the file is saved by specifying the output file path in the YAML file.

# Known issues

As mentioned above, both CWL and Toil are under active and rapid development, and new version may not be always backward compatible. Sentieon is actively improving cwltoil as well as Sentieon pipelines, to make them more efficient and user-friendly.

Currently, we have found the following known issues:
-   In cwltoil, the input/output for each stage must be read from/written to the job store. With large files, this can lead to significant runtime spent on unnecessary file copying between compute nodes.
-   All input VCF files should be in `.vcf.gz` format with `.tbi` index files. Uncompressed VCF with .idx index files are not supported at the moment.
