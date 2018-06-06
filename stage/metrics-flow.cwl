cwlVersion: v1.0
class: Workflow
doc: "Run metrics workflow"
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    secondaryFiles:
      - .fai
  input_bam:
    type:
    - "null"
    - type: array
      items: [string, File]
    secondaryFiles:
      - .bai
  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]

  interval:
    type: ["null", string, File]

  threads:
    type: ["null", int]
    
  mq_output:
    type: ["null", string]

  qd_output:
    type: ["null", string]

  gc_output:
    type: ["null", string]

  align_stat_output:
    type: ["null", string]

  isize_output:
    type: ["null", string] 

  plot_output:
    type: string

outputs:
  metrics_plot:
    type: ["null", File]
    outputSource: plot/output
  mq_metrics:
    type: ["null", File]
    outputSource: metrics/mq_metrics
  qd_metrics:
    type: ["null", File]
    outputSource: metrics/qd_metrics
  gc_metrics:
    type: ["null", File]
    outputSource: metrics/gc_metrics
  isize_metrics:
    type: ["null", File]
    outputSource: metrics/isize_metrics
  align_stat_metrics:
    type: ["null", File]
    outputSource: metrics/align_stat_metrics

steps:
  metrics:
    in:
      input_bam: input_bam
      reference: reference
      qcal: qcal
      interval: interval
      threads: threads
      mq_output: mq_output
      qd_output: qd_output
      gc_output: gc_output
      align_stat_output: align_stat_output
      isize_output: isize_output      
    out: [mq_metrics, qd_metrics, gc_metrics, align_stat_metrics, isize_metrics]
    run: ../algo/metrics.cwl
  
  plot:
    in:
      mq: metrics/mq_metrics
      qd: metrics/qd_metrics
      gc: metrics/gc_metrics
      isize: metrics/isize_metrics
      output_file: 
        source: plot_output
      fun: 
        valueFrom: ${ return "metrics"; }
    out: [output]
    run: ../algo/plot.cwl


