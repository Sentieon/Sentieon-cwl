cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    inputBinding:
      position: 10
      prefix: -r
    secondaryFiles:
      - .fai

  input_bam:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -i
    inputBinding:
      position: 10
    secondaryFiles:
      - .bai

  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -q
    inputBinding:
      position: 10
  
  interval:
    type: ["null", string, File]
    inputBinding:
      prefix: --interval
      position: 10

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10

 # algo starts with big position 100
  algo:
    type: string
    default: "CoverageMetrics"
    inputBinding:
      position: 100
      prefix: --algo

  min_map_qual:
    type: int?
    inputBinding:
      position: 110
      prefix: --min_map_qual

  max_map_qual:
    type: int?
    inputBinding:
      position: 110
      prefix: --max_map_qual

  min_base_qual:
    type: int?
    inputBinding:
      position: 110
      prefix: --min_base_qual

  max_base_qual:
    type: int?
    inputBinding:
      position: 110
      prefix: --max_base_qual

  count_type:
    type: int?
    inputBinding:
      position: 110
      prefix: --count_type

  gene_list:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --gene_list

  print_base_counts:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --print_base_counts
    
  omit_base_output:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --omit_base_output

  omit_locus_stat:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --omit_locus_stat

  omit_interval_stat:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --omit_interval_stat

  omit_sample_stat:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --omit_sample_stat

  include_ref_N:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --include_ref_N

  ignore_del_sites:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --ignore_del_sites

  include_del:
    type: boolean?
    inputBinding:
      position: 110
      prefix: --include_del

  partition:
    type:
    - "null"
    - type: array
      items: string
      inputBinding:
        prefix: --partition
    inputBinding:
      position: 110

  cov_thresh:
    type:
    - "null"
    - type: array
      items: int
      inputBinding:
        prefix: --cov_thresh
    inputBinding:
      position: 110


  output_file:
    type: string
    inputBinding:
      position: 150

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 110    

outputs:
  output:
    type: File[]
    outputBinding:
      glob: $(inputs.output_file)*
  log:
    type: stderr
stderr: coverage.log


