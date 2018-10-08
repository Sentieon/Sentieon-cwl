cwlVersion: v1.0
class: Workflow
doc: "DNAseq pipeline from fastq to vcf in distributed mode"
requirements:
  - class: ShellCommandRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    secondaryFiles:
      - .fai
      - .bwt
      - .sa
      - .ann
      - .amb
      - .pac
  input_reads:
    type: 
      type: array
      items: [string, File]
  input_reads_index_file:
    type: [string, File]
  extract_chunks:
    type: string[]
  sort_output_bam:
    type: string

  minimum_seed_length:
    type: int?
  min_std_max_min:
    type: int[]?
  readgroup:
    type: string?
  platform:
    type: string?
    default: ILLUMINA
  sample:
    type: string?
  library:
    type: string?
    default: library
  mark_secondary:
    type: boolean?
  chunk_size:
    type: int
  bam_compression:
    type: int?
  sort_reference:
    type: ["null", string, File]
    secondaryFiles:
      - .fai

  dedup_output_bam:
    type: string
  dedup_metrics_output_file:
    type: string
  realign_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  bqsr_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  realign_output_bam:
    type: string
  qcal_output_file:
    type: string
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  output_file:
    type: string
  interval:
    type: ["null", string, File]
  threads:
    type: ["null", int]
  shard:
    type: string[]

outputs:
  sort_output:
    type: File
    outputSource: sort_merge/output
  dedup_output:
    type: File
    outputSource: dedup/output
  dedup_metric_output:
    type: ["null", File]
    outputSource: dedup/metrics_output
  qcal_output:
    type: File
    outputSource: bqsr/output
  qcal_plot_output:
    type: ["null", File]
    outputSource: bqsr/plot_output
  qcal_plot_csv_output:
    type: ["null", File]
    outputSource: bqsr/plot_csv_output
  output:
    type: File
    outputSource: hc/output    

steps:
  bwa:
    in:
      reference: reference
      sort_reference: sort_reference
      reads: input_reads
      reads_index_file: input_reads_index_file
      mark_secondary: mark_secondary
      min_std_max_min: min_std_max_min
      minimum_seed_length: minimum_seed_length
      chunk_size: chunk_size
      extract_chunks: extract_chunks
      _output: sort_output_bam # to provide base name for output_file
      _extract_chunks: extract_chunks
      _ext: {"default":".bam"}
      output_file:
        source: extract_chunks
        linkMerge: merge_flattened
        valueFrom: |
          ${
            var len = inputs._extract_chunks.length;
            var i = 0;
            for (; i < len; ++i) {
               if (self == inputs._extract_chunks[i])
                 break;
            }
            return inputs._output + "_part_" + i + inputs._ext;
          }
      threads: threads
      sort_threads: threads
      bam_compression: bam_compression
      _readgroup: readgroup
      _sample: sample
      _platform: platform
      _library: library
      readgroup:
        valueFrom: |
          ${
            var rg = "@RG\tID:" + inputs._readgroup + "\tSM:" + inputs._sample
                     + "\tPL:" + inputs._platform;
            if ( inputs._library != null ) rg += "\tLB:" + inputs._library;
            return rg;
          }
    out: [output]
    scatter: [extract_chunks, output_file]
    scatterMethod: dotproduct
    run: ../algo/bwa-mem-sort-with-fastq-slicer.cwl

  sort_merge:
    in:
      threads: threads
      mergemode:
          valueFrom: ${ return 0; }
      input_bam:
        source: bwa/output
      output_file: sort_output_bam
    out: [output]
    run: ../algo/bam-merge.cwl

  dedup:
    in:
      reference: reference
      input_bam:
          source: bwa/output
      metrics_output_file: dedup_metrics_output_file
      output_file: dedup_output_bam
      shard: shard
      threads: threads
      interval: interval
    out: [output, metrics_output]      
    run: ../stage/dedup-2-pass-distr.cwl
  bqsr:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: bqsr_known_sites
      output_file: qcal_output_file
      shard: shard
      threads: threads
      interval: interval
    out: [output]
    run: ../stage/bqsr-distr.cwl
  hc:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      dbsnp: dbsnp
      output_file: output_file
      shard: shard
      threads: threads
      interval: interval
      qcal: 
        source: bqsr/output
        valueFrom: ${ return [ self ]; } # convert one element to array
    out: [output]
    run: ../stage/hc-distr.cwl


