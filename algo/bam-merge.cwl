cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, util, merge]
doc: "merge sorted bam files. If input bam files are in the order of coordinate, and no overlap, mergemode 10 can be used"
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1 

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
    - type: array
      items: [string, File]
    inputBinding:
      position: 100
    secondaryFiles:
      - .bai
  
  mergemode:
    type: ["null", int]
    default: 10
    inputBinding:
      prefix: --mergemode
      position: 10

  output_file:
    type: string
    inputBinding:
      prefix: -o
      position: 50

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
      
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      - .bai
  log:
    type: stderr
stderr: bam-merge.log


