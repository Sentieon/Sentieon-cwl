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

  interval:
    type: ["null", string, File]
    inputBinding:
      prefix: --interval
      position: 10

  shard:
    type: ["null", string]
    inputBinding:
      prefix: --shard
      position: 10

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10
    
 # algo starts with big position 100
  algo:
    type: string
    default: "GVCFtyper"
    inputBinding:
      position: 100
      prefix: --algo
  
  dbsnp:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  input_vcf:
    type: 
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -v
    inputBinding:
      position: 110      
    secondaryFiles:
      - .tbi 

  annotation:
    type:
    - "null"
    - type: array
      items: string
    inputBinding:
      prefix: --annotation
      position: 110

  call_conf:
    type: ["null", double]
    inputBinding:
      prefix: --call_conf
      position: 110  

  emit_conf:
    type: ["null", double]
    inputBinding:
      prefix: --emit_conf
      position: 110  

  emit_mode:
    type: ["null", string]
    inputBinding:
      prefix: --emit_mode
      position: 110  

  max_alt_alleles:
    type: ["null", int]
    inputBinding:
      prefix: --max_alt_alleles
      position: 110  

  output_file:
    type: string
    inputBinding:
      position: 150

# for merge metrics, after output_file
  merge:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --merge
      position: 110  
  part_output:
    type:
      - "null"
      - type: array
        items: [string, File]
    inputBinding:
      position: 180
    secondaryFiles:
      - .tbi

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
  log:
    type: stderr
stderr: gvcf.log


