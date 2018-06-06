cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, util, index]
doc: "sort sam/bam files."
requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: [ $(inputs.input) ]
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

  input:
    type: [string, File]
    inputBinding:
      position: 100
      valueFrom: $(self.basename)

outputs:
  output:
    type: File   
    secondaryFiles: .bai
    outputBinding:
      glob: $(inputs.input.basename)

  log:
    type: stderr
stderr: bam-index.log


