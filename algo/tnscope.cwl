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
      items: File
      inputBinding:
        prefix: -q
    inputBinding:
      position: 10

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
    default: "TNscope"
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

  given:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  pcr_indel_model:
    type: ["null", string]
    inputBinding:
      prefix: --pcr_indel_model
      position: 110  

  min_base_qual:
    type: ["null", int]
    inputBinding:
      prefix: --min_base_qual
      position: 110  

  phasing:
    type: ["null", int]
    inputBinding:
      prefix: --phasing
      position: 110  

  prune_factor:
    type: ["null", int]
    inputBinding:
      prefix: --prune_factor
      position: 110  

  normal_sample:
    type: ["null", string]
    inputBinding:
      prefix: --normal_sample
      position: 110  

  tumor_sample:
    type: ["null", string]
    inputBinding:
      prefix: --tumor_sample
      position: 110  

  cosmic:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  pon:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  min_init_tumor_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_init_tumor_lod
      position: 110  

  min_init_normal_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_init_normal_lod
      position: 110  
 
  min_tumor_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_tumor_lod
      position: 110

  min_normal_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_normal_lod
      position: 110

  min_dbsnp_normal_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_dbsnp_normal_lod
      position: 110

  tumor_contamination_frac:
    type: ["null", double]
    inputBinding:
      prefix: --tumor_contamination_frac
      position: 110

  normal_contamination_frac:
    type: ["null", double]
    inputBinding:
      prefix: --normal_contamination_frac
      position: 110

  sv_mask_ext:
    type: ["null", int]
    inputBinding:
      prefix: --sv_mask_ext
      position: 110

  sv_mask_cmd:
    type: ["null", string]
    inputBinding:
      prefix: --sv_mask_cmd
      position: 110

  sv_data_tmp_output_file:
    type: string?
    inputBinding:
      prefix: --sv_data_tmp_output
      position: 110
  sv_mate_tmp_output_file:
    type: string?
    inputBinding:
      prefix: --sv_mate_tmp_output
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

  merge_sv_data:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --merge_sv_data
      position: 110

  merge_sv_mate:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --merge_sv_mate
      position: 110

  sv_solver:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --sv_solver
      position: 110

  #sv_data_tmp_file/sv_mate_tmp_file/pre_output required for sv_solver mode
  sv_data_tmp_file:
    type: File?
    inputBinding:
      prefix: --sv_data_tmp_output
      position: 110
    secondaryFiles:
      - .tbi
  sv_mate_tmp_file:
    type: File?
    inputBinding:
      prefix: --sv_mate_tmp_output
      position: 110
    secondaryFiles:
      - .tbi
  pre_output:
    type: File?
    inputBinding:
      prefix: --pre_output
      position: 110
    secondaryFiles:
      - .tbi

  part_output:
    type:
      - "null"
      - type: array
        items: File
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
  sv_data_tmp_output:
    type: File?
    outputBinding:
      glob: $(inputs.sv_data_tmp_output_file)
    secondaryFiles:
      - .tbi
  sv_mate_tmp_output:
    type: File?
    outputBinding:
      glob: $(inputs.sv_mate_tmp_output_file)
    secondaryFiles:
      - .tbi
  log:
    type: stderr
stderr: tnscope.log


