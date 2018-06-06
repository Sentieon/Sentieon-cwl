cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, plot]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 1

inputs:
  fun:
    type: string
    inputBinding: 
      position: 1
  input:
    type: ["null", File]
    inputBinding:
      position: 20
  output_file:
    type: string
    inputBinding:
      position: 10
      prefix: -o

#  vqsr options
  tranches_file:
    type: ["null", File]
    inputBinding:
      position: 50
      separate: false
      prefix: "tranches_file="
  target_titv:
    type: ["null", double]
    inputBinding:
      position: 50
      separate: false
      prefix: "target_titv="
  min_fp_rate:
    type: ["null", double]
    inputBinding:
      position: 50
      separate: false
      prefix: "min_fp_rate="
  point_size:
    type: ["null", double]
    inputBinding:
      position: 50
      separate: false
      prefix: "point_size="
# metrics options
  gc:
    type: ["null", File]
    inputBinding:
      position: 50
      separate: false
      prefix: "gc="
  mq:
    type: ["null", File]
    inputBinding:
      position: 50
      separate: false
      prefix: "mq="
  qd:
    type: ["null", File]
    inputBinding:
      position: 50
      separate: false
      prefix: "qd="
  isize:
    type: ["null", File]
    inputBinding:
      position: 50
      separate: false
      prefix: "isize="
    
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
  log:
    type: stderr
stderr: plot.log


