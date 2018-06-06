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
    default: "CNV"
    inputBinding:
      position: 100
      prefix: --algo
  
  target:
    type: [string, File]
    inputBinding:
      prefix: --target
      position: 110

  target_padding:
    type: ["null", int]
    inputBinding:
      prefix: --target_padding
      position: 110  

  create_pon:
    type: ["null", boolean]
    inputBinding:
      prefix: --create_pon
      position: 110  

  pon:
    type: ["null", string, File]
    inputBinding:
      prefix: --pon
      position: 110

  coverage:
    type: ["null", File]
    inputBinding:
      prefix: --coverage
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
    type: File
    outputBinding:
      glob: $(inputs.output_file)

  log:
    type: stderr
stderr: cnv.log


