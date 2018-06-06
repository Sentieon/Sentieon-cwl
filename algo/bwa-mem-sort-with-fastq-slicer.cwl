#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reads:
    type:
      type: array
      items: [string, File]
    inputBinding:
      position: 5
  reads_index_file:
    type: [string, File]
    inputBinding:
      position: 3
      prefix: -i
  extract_chunks:
    type: string?
    inputBinding:
      position: 3
      prefix: -r
   
  minimum_seed_length:
    type: int?
    inputBinding:
      position: 11
      prefix: -k
    doc: -k INT        minimum seed length [19]
  reference:
    type: [string, File]
    inputBinding:
      position: 12
    secondaryFiles:
      - .fai
      - .bwt
      - .sa
      - .ann
      - .amb
      - .pac
  threads:
    type: int?
    inputBinding:
      position: 11
      prefix: -t
    doc: -t INT        number of threads [1]
  min_std_max_min:
    type: int[]?
    inputBinding:
      position: 11
      prefix: -I
      itemSeparator: ','
  readgroup:
    type: string?
    inputBinding:
      position: 11
      prefix: -R
  mark_secondary:
    type: boolean?    
    inputBinding:
      position: 11
      prefix: -M
  chunk_size:
    type: int?
    inputBinding:
      position: 11
      prefix: -K
  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 11

  # util-sort options
  output_file:
    type: string
    inputBinding:
      position: 110
      prefix: -o
  sort_threads:
    type: int?
    inputBinding:
      position: 110
      prefix: -t
  bam_compression:
    type: int?
    inputBinding:
      prefix: --bam_compression
      position: 110
  sort_reference:
    type: ["null", string, File]
    inputBinding:
      prefix: -r
      position: 110    
    secondaryFiles:
      - .fai

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      - .bai
  bwa_log:
    type: File
    outputBinding:
      glob: "bwa-mem.log"
  
  sort_log:
    type: File
    outputBinding:
      glob: "util-sort.log"
  
arguments: #fastq slicer + bwa mem + util sort
  - {valueFrom: "sentieon", position: 0}
  - {valueFrom: "fqidx", position: 0}
  - {valueFrom: "extract", position: 0}
  - {valueFrom: "2> fastq-slice.log", position: 8, shellQuote: false}
  - {valueFrom: "|", position: 9, shellQuote: false}
  - {valueFrom: "bwa", position: 10}
  - {valueFrom: "mem", position: 10}
  - {valueFrom: "-p", position: 10}
  - {valueFrom: "-", position: 13} #after reference
  - {valueFrom: "2> bwa-mem.log", position: 90, shellQuote: false}
  - {valueFrom: "|", position: 90, shellQuote: false}
  - {valueFrom: "sentieon", position: 100}
  - {valueFrom: "util", position: 100}
  - {valueFrom: "sort", position: 100}
  - {valueFrom: "--sam2bam", position: 110}
  - {valueFrom: "-", position: 110}
  - {valueFrom: "2> util-sort.log", position: 120, shellQuote: false}

  



