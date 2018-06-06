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

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
    
  mq_output:
    type: ["null", string]
    inputBinding:
      position: 150      
      prefix: "--algo"
      valueFrom: ${ return ["MeanQualityByCycle", self]; }
  
  qd_output:
    type: ["null", string]
    inputBinding:
      position: 150      
      prefix: "--algo"
      valueFrom: ${ return ["QualDistribution", self]; }

  gc_output:
    type: ["null", string]
    inputBinding:
      position: 150      
      prefix: "--algo"
      valueFrom: ${ return ["GCBias", "--summary", self+".summary.txt", self]; }

  align_stat_output:
    type: ["null", string]
    inputBinding:
      position: 150      
      prefix: "--algo"
      valueFrom: ${ return ["AlignmentStat", self]; }

  isize_output:
    type: ["null", string] 
    inputBinding:
      position: 150      
      prefix: "--algo"
      valueFrom: ${ return ["InsertSizeMetricAlgo", self]; }

outputs:
  mq_metrics:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.mq_output)
  qd_metrics:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.qd_output)
  gc_metrics:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.gc_output)
    secondaryFiles:
      .summary.txt
  align_stat_metrics:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.align_stat_output)
  isize_metrics:
    type: ["null", File]
    outputBinding:
      glob: $(inputs.isize_output)
  log:
    type: stderr
stderr: metrics.log


