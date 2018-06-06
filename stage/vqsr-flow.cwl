cwlVersion: v1.0
class: Workflow
doc: "run vqsr flow, including vqsr rcal, vqsr apply and plot"
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    secondaryFiles:
      - .fai

  var_type:
    type: ["null", string]

  input_vcf:
    type: [string, File]
    secondaryFiles:
      - .tbi 
  
  # require resource and resource_param in pairs
  resources:
    type:
      type: array
      items:
      - type: record
        name: resource
        fields:
          - name: resource
            type: [string, File]
            inputBinding:
              prefix: --resource
          - name: resource_param
            type: string
            inputBinding:
              prefix: --resource_param

  annotation:
    type: string[]

  aggregate_data:
    type:
    - "null"
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi

  max_gaussians:
    type: ["null", int]

  max_neg_gaussians:
    type: ["null", int]

  max_iter:
    type: ["null", int]

  max_mq:
    type: ["null", double]

  srand:
    type: ["null", long]

  sensitivity:
    type: ["null", double]

  output_file:
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
        - name: vqsr_recal
          type:
          - "null"
          - type: array
            items: string
        - name: vqsr_apply
          type:
          - "null"
          - type: array
            items: string

outputs:
  output:
    type: File
    outputSource: vqsr_apply/output
  plot_output:
    type: ["null", File]
    outputSource: plot/output
  tranches_output:
    type: File
    outputSource: vqsr_recal/tranches_output    

steps:
  vqsr_recal:
    in:
      input_vcf: input_vcf
      reference: reference
      threads: threads
      var_type: var_type
      resources: resources
      annotation: annotation
      aggregate_data: aggregate_data
      max_gaussians: max_gaussians
      max_neg_gaussians: max_neg_gaussians
      max_iter: max_iter
      max_mq: max_mq
      srand: srand
      plot_file:
        source: output_file
        valueFrom: $(self).plot
      tranches_file:
        source: output_file
        valueFrom: $(self).tranches
      output_file: 
        source: output_file
        valueFrom: $(self).recal.gz
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.vqsr_recal : []; }
    out: [output, tranches_output, plot_output]
    run: ../algo/vqsr-recal.cwl

  vqsr_apply:
    in:
      input_vcf: input_vcf
      reference: reference
      var_type: var_type
      threas: threads
      sensitivity: sensitivity
      recal: vqsr_recal/output
      tranches_file: vqsr_recal/tranches_output
      output_file: output_file
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.vqsr_apply : []; }
    out: [output]
    run: ../algo/vqsr-apply.cwl
  
  plot:
    in:
      output_file: 
        source: output_file
        valueFrom: $(self).pdf
      input: vqsr_recal/plot_output
      tranches_file: vqsr_recal/tranches_output
      fun: 
        valueFrom: ${ return "vqsr"; }
    out: [output]
    run: ../algo/plot.cwl


