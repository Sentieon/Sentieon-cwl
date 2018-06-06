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

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10

  traverse_param:
    type: ["null", string]
    inputBinding:
      prefix: --traverse_param
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
    
 # algo starts with big position 100
  algo:
    type: string
    default: "Dedup"
    inputBinding:
      position: 100
      prefix: --algo

  score_info:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: --score_info
    inputBinding:
      position: 110
    secondaryFiles:
      - .tbi

  rmdup:
    type: ["null", boolean]
    default: true
    inputBinding:      
      prefix: --rmdup
      position: 110

  metrics:
    type: ["null", string]
    inputBinding:
      prefix: --metrics
      position: 110

  optical_dup_pix_dist:
    type: ["null", int]
    inputBinding:
      prefix: --optical_dup_pix_dist
      position: 110

  # output_dup_read_name and dup_read_name is for 3-pass dedup flow, i.e., dedup by qname
  output_dup_read_name:
    type: ["null", boolean]
    default: false
    inputBinding:      
      prefix: --output_dup_read_name
      position: 110

  dup_read_name:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: --dup_read_name
    inputBinding:
      position: 110  

  bam_compression:
    type: int?
    inputBinding:
      prefix: --bam_compression
      position: 110

  output_file:
    type: string
    inputBinding:
      position: 150

# for merge metrics, after output_file
  merge:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --merge
      position: 110  
  part_metrics:
    type:
      - "null"
      - type: array
        items: [string, File]
    inputBinding:
      position: 180

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
      .bai
  metrics_output:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.metrics)
  log:
    type: stderr
stderr: dedup.log


