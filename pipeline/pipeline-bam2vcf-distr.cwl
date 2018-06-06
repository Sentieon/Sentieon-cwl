cwlVersion: v1.0
class: Workflow
doc: "DNAseq pipeline from bam to vcf in distributed mode"
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    secondaryFiles:
      - .fai
  input_bam:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .bai
  dedup_output_bam:
    type: string
  dedup_metrics_output_file:
    type: string
  realign_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  bqsr_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  realign_output_bam:
    type: string
  qcal_output_file:
    type: string
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  output_file:
    type: string
  interval:
    type: ["null", File]
  threads:
    type: ["null", int]
  shard:
    type: string[]

outputs:
  dedup_output:
    type: File
    outputSource: dedup/output
  dedup_metric_output:
    type: ["null", File]
    outputSource: dedup/metrics_output
  realign_output:
    type: File
    outputSource: realign/output  
  qcal_output:
    type: File
    outputSource: bqsr/qcal_output
  qcal_plot_output:
    type: ["null", File]
    outputSource: bqsr/plot_output
  output:
    type: File
    outputSource: hc/output    

steps:
  dedup:
    in:
      reference: reference
      input_bam: input_bam
      metrics_output_file: dedup_metrics_output_file
      output_file: dedup_output_bam
      shard: shard
      threads: threads
      interval: interval
    out: [output, metrics_output]      
    run: ../stage/dedup-2-pass-distr.cwl
  realign:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: realign_known_sites
      output_file: realign_output_bam
      shard: shard
      threads: threads
      interval_list: interval
    out: [output]
    run: ../stage/realign-distr.cwl
  bqsr:
    in:
      reference: reference
      input_bam: 
        source: realign/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: bqsr_known_sites
      output_file: qcal_output_file
      plot_output_file: 
        source: qcal_output_file
        valueFrom: ${ return self + ".pdf"; }
      plot_output_csv_file:
        source: qcal_output_file
        valueFrom: ${ return self + ".csv"; }
      shard: shard
      threads: threads
      interval: interval
    out: [qcal_output, plot_output]
    run: ../stage/bqsr-flow-distr.cwl
  hc:
    in:
      reference: reference
      input_bam: 
        source: realign/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      dbsnp: dbsnp
      output_file: output_file
      shard: shard
      threads: threads
      interval: interval
      qcal: 
        source: bqsr/qcal_output
        valueFrom: ${ return [ self ]; } # convert one element to array
    out: [output]
    run: ../stage/hc-distr.cwl


