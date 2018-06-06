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
    default: "TNsnv"
    inputBinding:
      position: 100
      prefix: --algo

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

  pon_sample:
    type: ["null", string]
    inputBinding:
      prefix: --pon_sample
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

  contamination_frac:
    type: ["null", double]
    inputBinding:
      prefix: --contamination_frac
      position: 110

  min_cell_mutation_frac:
    type: ["null", double]
    inputBinding:
      prefix: --min_cell_mutation_frac
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

  min_normal_allele_frac:
    type: ["null", double]
    inputBinding:
      prefix: --min_normal_allele_frac
      position: 110

  min_tumor_allele_frac:
    type: ["null", double]
    inputBinding:
      prefix: --min_tumor_allele_frac
      position: 110

  max_indel:
    type: ["null", int]
    inputBinding:
      prefix: --max_indel
      position: 110

  max_read_clip_frac:
    type: ["null", double]
    inputBinding:
      prefix: --max_read_clip_frac
      position: 110

  max_mapq0_frac:
    type: ["null", double]
    inputBinding:
      prefix: --max_mapq0_frac
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

  max_alt_mapq:
    type: ["null", double]
    inputBinding:
      prefix: --max_alt_mapq
      position: 110
  
  max_normal_alt_cnt:
    type: ["null", int]
    inputBinding:
      prefix: --max_normal_alt_cnt
      position: 110

  max_normal_alt_qsum:
    type: ["null", int]
    inputBinding:
      prefix: --max_normal_alt_qsum
      position: 110

  max_normal_alt_frac:
    type: ["null", double]
    inputBinding:
      prefix: --max_normal_alt_frac
      position: 110

  power_allele_frac:
    type: ["null", double]
    inputBinding:
      prefix: --power_allele_frac
      position: 110

  dbsnp:
    type: ["null", string, File]
    inputBinding:
      prefix: -d
      position: 110
    secondaryFiles:
      - .tbi

  call_stats_out_file:
    type: string?
    inputBinding:
      prefix: --call_stats_out
      position: 110
  stdcov_out_file:
    type: string?
    inputBinding:
      prefix: --stdcov_out
      position: 110
  q20cov_out_file:
    type: string?
    inputBinding:
      prefix: --q20cov_out
      position: 110
  power_out_file:
    type: string?
    inputBinding:
      prefix: --power_out
      position: 110
  tumor_depth_out_file:
    type: string?
    inputBinding:
      prefix: --tumor_depth_out
      position: 110
  normal_depth_out_file:
    type: string?
    inputBinding:
      prefix: --normal_depth_out
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

  merge_txt:
    type: ["null", boolean]
    default: false
    inputBinding:
      prefix: --merge_txt
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
  call_stats_output:
    type: File?
    outputBinding:
      glob: $(inputs.call_stats_out_file)
  stdcov_output:
    type: File?
    outputBinding:
      glob: $(inputs.stdcov_out_file)
  q20cov_output:
    type: File?
    outputBinding:
      glob: $(inputs.q20cov_out_file)
  power_output:
    type: File?
    outputBinding:
      glob: $(inputs.power_out_file)
  tumor_depth_output:
    type: File?
    outputBinding:
      glob: $(inputs.tumor_depth_out_file)
  normal_depth_output:
    type: File?
    outputBinding:
      glob: $(inputs.normal_depth_out_file)

  log:
    type: stderr
stderr: tnsnv.log


