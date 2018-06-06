cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
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
    
 # algo starts with big position 100
  algo:
    type: string
    default: "ContaminationAssessment"
    inputBinding:
      position: 100
      prefix: --algo
  

  type:
    type: ["null", string]
    inputBinding:    
      position: 110
      prefix: --type

  min_bq:
    type: ["null", int]
    inputBinding:    
      position: 110
      prefix: --min_bq

  min_map_qual:
    type: ["null", int]
    inputBinding:    
      position: 110
      prefix: --min_map_qual

  trim_frac:
    type: ["null", double]
    inputBinding:    
      position: 110
      prefix: --trim_frac

  trim_thresh:
    type: ["null", double]
    inputBinding:    
      position: 110
      prefix: --trim_thresh

  precision:
    type: ["null", double]
    inputBinding:    
      position: 110
      prefix: --precision

  min_basecount:
    type: ["null", int]
    inputBinding:    
      position: 110
      prefix: --min_basecount

  population:
    type: ["null", string]
    inputBinding:    
      position: 110
      prefix: --population

  pop_vcf:
    type: [string, File]
    inputBinding:    
      position: 110
      prefix: --pop_vcf
    secondaryFiles:
      - .tbi

  genotype_vcf:
    type: ["null", string, File]
    inputBinding:    
      position: 110
      prefix: --genotype_vcf
    secondaryFiles:
      - .tbi

  base_report_output_file:
    type: ["null", string]
    inputBinding:
      position: 110
      prefix: --base_report

  output_file:
    type: string
    inputBinding:
      position: 150

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 110    
   
outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.output_file)
  base_report_output:
    type: File?
    outputBinding:
      glob: $(inputs.base_report_output_file)
  log:
    type: stderr
stderr: contam-est.log


