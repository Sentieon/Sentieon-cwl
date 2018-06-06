cwlVersion: v1.0
class: Workflow
requirements:
  - class: ShellCommandRequirement
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
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
    - type: array
      items: [string, File]
  input_reads_index_file:
    type: [string, File]
  extract_chunks:   
    type: string[]

  minimum_seed_length:
    type: int?
  threads:
    type: int?
  min_std_max_min:
    type: int[]?
  readgroup:
    type: string?
  platform:
    type: string?
  sample:
    type: string?
  library:
    type: string?    
  mark_secondary:
    type: boolean?    
  chunk_size:
    type: int?

  sort_threads:
    type: int?
  bam_compression:
    type: int?
  sort_reference:
    type: ["null", string, File]
    secondaryFiles:
      - .fai
  output_file:
    type: string
  advanced_options:
    type: 
    - "null"
    - type: array
      items: string

outputs:
  output:
    type: File
    outputSource: merge/output
    secondaryFiles:
      - .bai
  
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
      _output: output_file # to provide base name for output_file
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

  merge:
    in:
      threads: threads
      mergemode:
          valueFrom: ${ return 0; }
      input_bam:
        source: bwa/output
      output_file: output_file
    out: [output]
    run: ../algo/bam-merge.cwl



