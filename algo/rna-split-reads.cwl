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
    - File
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
        position: 10

  interval:
    type: ["null", string, File]
    inputBinding:
      prefix: --interval
      position: 10
   
 # algo starts with big position 100
  algo:
    type: string
    default: "RNASplitReadsAtJunction"
    inputBinding:
      position: 100
      prefix: --algo
  
  reassign_mapq:
    type: string
    default: "255:60"
    inputBinding:    
      position: 110
      prefix: --reassign_mapq

  ignore_overhang:
    type: ["null", boolean]
    inputBinding:    
      position: 110
      prefix: --ignore_overhang

  overhang_max_bases:
    type: ["null", int]
    inputBinding:    
      position: 110
      prefix: --overhang_max_bases

  overhang_max_mismatches:
    type: ["null", int]
    inputBinding:    
      position: 110
      prefix: --overhang_max_mismatches

  output_file:
    type: string
    inputBinding:
      position: 150

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10

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
stderr: rna-split-reads.log


