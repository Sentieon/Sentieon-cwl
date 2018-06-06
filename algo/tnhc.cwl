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
      items: [string, File]
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
    default: "TNhaplotyper"
    inputBinding:
      position: 100
      prefix: --algo

  pcr_indel_model:
    type: ["null", string]
    inputBinding:
      prefix: --pcr_indel_model
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

  min_base_qual:
    type: ["null", int]
    inputBinding:
      prefix: --min_base_qual
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

  detect_pon:
    type: ["null", boolean]
    inputBinding:
      prefix: --detect_pon
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

  filter_clustered_read_position:
    type: ["null", int]
    inputBinding:
      prefix: --filter_clustered_read_position
      position: 110

  filter_strand_bias:
    type: ["null", int]
    inputBinding:
      prefix: --filter_strand_bias
      position: 110

  min_strand_bias_lod:
    type: ["null", double]
    inputBinding:
      prefix: --min_strand_bias_lod
      position: 110

  min_strand_bias_power:
    type: ["null", double]
    inputBinding:
      prefix: --min_strand_bias_power
      position: 110

  min_pir_median:
    type: ["null", double]
    inputBinding:
      prefix: --min_pir_median
      position: 110

  min_pir_mad:
    type: ["null", double]
    inputBinding:
      prefix: --min_pir_mad
      position: 110

  dbsnp:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

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
stderr: tnhc.log


