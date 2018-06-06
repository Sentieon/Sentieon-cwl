cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
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
    default: "Realigner"
    inputBinding:
      position: 100
      prefix: --algo
  
  known_sites:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -k
    inputBinding:
      position: 110
    secondaryFiles:
      - .tbi

  interval_list:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --interval_list

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
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      .bai
  log:
    type: stderr
stderr: realign.log


