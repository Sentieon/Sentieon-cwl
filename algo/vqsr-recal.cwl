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
    default: "VarCal"
    inputBinding:
      position: 100
      prefix: --algo

  var_type:
    type: ["null", string]
    inputBinding:
      position: 110
      prefix: --var_type

  input_vcf:
    type: [string, File]
    inputBinding:
      position: 110
      prefix: --vcf
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
            secondaryFiles:
              - .tbi 
          - name: resource_param
            type: string
            inputBinding:
              prefix: --resource_param
    inputBinding:
      position: 110

  annotation:
    type:
    - type: array
      items: string
      inputBinding:
        prefix: --annotation
    inputBinding:
      position: 110

  aggregate_data:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: --aggregate_data
    inputBinding:
      position: 110
    secondaryFiles:
      - ${
          var f = self.basename; 
          if (f.split(".").pop() == "gz") return f + ".tbi"; else return f + ".idx"; 
        }

  max_gaussians:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --max_gaussians

  max_neg_gaussians:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --max_neg_gaussians

  max_iter:
    type: ["null", int]
    inputBinding:
      position: 110
      prefix: --max_iter

  max_mq:
    type: ["null", double]
    inputBinding:
      position: 110
      prefix: --max_mq

  srand:
    type: ["null", long]
    inputBinding:
      position: 110
      prefix: --srand

  plot_file:
    type: ["null", string]
    inputBinding:
      position: 110
      prefix: --plot_file

  tranches_file:
    type: string
    inputBinding:
      position: 110
      prefix: --tranches_file

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
    secondaryFiles:
      - .tbi
      
  plot_output:
    type: File
    outputBinding:
      glob: $(inputs.plot_file)

  tranches_output:
    type: File
    outputBinding:
      glob: $(inputs.tranches_file)

  log:
    type: stderr
stderr: vqsr_recal.log


