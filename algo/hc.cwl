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

  shard:
    type: ["null", string]
    inputBinding:
      prefix: --shard
      position: 10
  traverse_param:
    type: ["null", string]
    inputBinding:
      prefix: --traverse_param
      position: 10

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
    
 # algo starts with big position 100
  algo:
    type: string
    default: "Haplotyper"
    inputBinding:
      position: 100
      prefix: --algo
  
  dbsnp:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi
  given:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  annotation:
    type:
    - "null"
    - type: array
      items: string
    inputBinding:
      prefix: --annotation
      position: 110

  call_conf:
    type: ["null", double]
    inputBinding:
      prefix: --call_conf
      position: 110  

  emit_conf:
    type: ["null", double]
    inputBinding:
      prefix: --emit_conf
      position: 110  

  emit_mode:
    type: ["null", string]
    inputBinding:
      prefix: --emit_mode
      position: 110  

  gq_bands:
    type: ["null", string]
    inputBinding:
      prefix: --gq_bands
      position: 110  

  pcr_indel_model:
    type: ["null", string]
    inputBinding:
      prefix: --pcr_indel_model
      position: 110  

  min_base_qual:
    type: ["null", int]
    inputBinding:
      prefix: --min_base_qual
      position: 110  

  phasing:
    type: ["null", int]
    inputBinding:
      prefix: --phasing
      position: 110  

  ploidy:
    type: ["null", int]
    inputBinding:
      prefix: --ploidy
      position: 110  

  prune_factor:
    type: ["null", int]
    inputBinding:
      prefix: --prune_factor
      position: 110  

  trim_soft_clip:
    type: ["null", boolean]
    inputBinding:
      prefix: --trim_soft_clip
      position: 110  

  output_file:
    type: string
    inputBinding:
      position: 150

# for merge metrics, after output_file
  merge:
    type: ["null", boolean]
    inputBinding:
      prefix: --merge
      position: 110  
  part_output:
    type:
      - "null"
      - type: array
        items: [string, File]
    inputBinding:
      position: 180
    secondaryFiles:
      - .tbi

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 110    

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      - .tbi
  log:
    type: stderr
stderr: hc.log


