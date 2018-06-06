cwlVersion: v1.0
class: Workflow
doc: "run 3-pass dedup: algo LocusCollector + algo Dedup output_dup_read_name + algo Dedup dedup_by_read_name sequentially"
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
    - type: array
      items: [string, File]
    secondaryFiles:
      - .bai
  metrics_output_file:
    type: string
  output_file:
    type: string
  interval:
    type: ["null", string, File]
  threads:
    type: ["null", int]
  bam_compression:
    type: int?
  traverse_param:
    type: string?

  advanced_options:
    type:
    - "null"
    - type: record
      fields:
        - name: dedup_pre
          type:
          - "null"
          - type: array
            items: string
        - name: dedup
          type:
          - "null"
          - type: array
            items: string

outputs:
  output:
    type: File
    outputSource: dedup_by_read_name/output
  metrics_output:
    type: ["null", File]
    outputSource: dup_read_name/metrics_output

steps:
  dedup_pre:
    in:
      input_bam: input_bam
      reference: reference
      output_file:
        source: output_file
        valueFrom: $(self).score.gz
      threads: threads
      traverse_param: traverse_param
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup_pre : []; }
    out: [output]
    run: ../algo/dedup_pre.cwl

  dup_read_name:
    in:
      input_bam: input_bam
      reference: reference
      score_info:
        source: dedup_pre/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      metrics: metrics_output_file
      output_dup_read_name: 
        valueFrom: ${ return true; }
      output_file:
        source: output_file
        valueFrom: $(self).dup_read_name.gz
      threads: threads
      traverse_param: traverse_param
      bam_compression: bam_compression
      interval: interval
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup : []; }
    out: [output, metrics_output]
    run: ../algo/dedup.cwl

  dedup_by_read_name:
    in:
      input_bam: input_bam
      reference: reference
      dup_read_name: 
        source: dup_read_name/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      output_file: output_file
      threads: threads
      traverse_param: traverse_param
      bam_compression: bam_compression
      interval: interval
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup : []; }
    out: [output]
    run: ../algo/dedup.cwl
    


