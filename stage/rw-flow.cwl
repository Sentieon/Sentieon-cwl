cwlVersion: v1.0
class: Workflow
doc: "run multiple rw stages sequentially using earlier step output as later stage input_bam"
requirements:
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    secondaryFiles:
      - .fai
  rw1_input_bam:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .bai
  rw1_output:
    type: string
  rw2_output:
    type: string 
  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
  advanced_options:
    type:
    - "null"
    - type: record
      fields:
        - name: rw1
          type:
          - "null"
          - type: array
            items: string
        - name: rw2
          type:
          - "null"
          - type: array
            items: string

outputs:
  output:
    type: File
    outputSource: rw2/output
steps:
  rw1:
    in:
      input_bam: rw1_input_bam
      reference: reference
      threads: threads
      output_file: rw1_output
      advanced_options:
        source: advanced_options
        valueFrom: ${ if (self.rw1) return self.rw1; else return null; }
    out: [output]
    run: ../algo/rw.cwl
  rw2:
    in:
      input_bam: 
        source: rw1/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      reference: reference
      threads: threads
      output_file: rw2_output
      advanced_options:
        source: advanced_options
        valueFrom: ${ if (self.rw2) return self.rw2; else return null; }
    out: [output]
    run: ../algo/rw.cwl


