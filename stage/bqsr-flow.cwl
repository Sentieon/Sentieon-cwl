cwlVersion: v1.0
class: Workflow
doc: "Run BQSR pre+post+plot flow"
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
  known_sites:
    type:
    - "null"
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  output_file:
    type: string 
  plot_output_file:
    type: ["null", string]
  plot_output_csv_file:
    type: ["null", string] 
  threads:
    type: ["null", int]

  interval:
    type: ["null", string, File]

  advanced_options:
    type:
    - "null"
    - type: record
      fields:
        - name: bqsr
          type:
          - "null"
          - type: array
            items: string
        - name: bqsr_post
          type:
          - "null"
          - type: array
            items: string

outputs:
  qcal_output:
    type: File
    outputSource: bqsr/output
  plot_output:
    type: ["null", File]
    outputSource: plot/output
  plot_csv_output:
    type: ["null", File]
    outputSource: bqsr_plot/output 

steps:
  bqsr:
    in:
      input_bam: input_bam
      reference: reference
      threads: threads
      known_sites: known_sites
      interval: interval
      output_file:
        source: output_file
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.bqsr : []; }
    out: [output]
    run: ../algo/bqsr.cwl

  bqsr_post:
    in:
      input_bam: input_bam
      reference: reference
      threads: threads
      interval: interval
      qcal:
        source: bqsr/output
        valueFrom: ${ return [ self ]; }
      output_file: 
        source: output_file
        valueFrom: $(self).post
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.bqsr_post : []; }
    out: [output]
    run: ../algo/bqsr.cwl
  
  bqsr_plot:
    in:
      threads: threads
      before: bqsr/output
      after: bqsr_post/output
      plot:    
        valueFrom: ${ return true; }
      output_file: 
        source: [output_file, plot_output_csv_file]
        valueFrom: |
          ${
            if(self[1] != null)
                return self[1];
            else
                return self[0] + ".csv";
          }    
    out: [output]
    run: ../algo/bqsr.cwl

  plot:
    in:
      input: bqsr_plot/output
      output_file: 
        source:  [output_file, plot_output_file]
        valueFrom: |
          ${
            if(self[1] != null)
                return self[1];
            else
                return self[0] + ".pdf";
          } 
      fun: 
        valueFrom: ${ return "bqsr"; }
    out: [output]
    run: ../algo/plot.cwl
      


