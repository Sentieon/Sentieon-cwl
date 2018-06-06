cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, util, sort]
doc: "sort sam/bam files."
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

  input:
    type:
    - type: array
      items: [string, File]
    inputBinding:
      position: 100
  
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

  sam2bam:
    type: boolean?
    inputBinding:
      prefix: --sam2bam
      position: 90

  bam_compression:
    type: int?
    inputBinding:
      prefix: --bam_compression
      position: 10
    
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      .bai
  log:
    type: stderr
stderr: bam-sort.log


