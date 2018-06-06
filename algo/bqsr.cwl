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

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
    
 # algo starts with big position 100
  algo:
    type: string
    default: "QualCal"
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
  plot:
    type: ["null", boolean]
    inputBinding:
      position: 110
      prefix: --plot
  before:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --before
  after:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --after
  other_qcal:
    type: ["null", string, File]
    inputBinding:
      position: 110
      prefix: --qcal    

  output_file:
    type: string
    inputBinding:
      position: 150

  merge:
    type: ["null", boolean]
    inputBinding:
      position: 110
      prefix: --merge
  part_output:
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
  log:
    type: stderr
stderr: bqsr.log


