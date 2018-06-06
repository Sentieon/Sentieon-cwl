cwlVersion: v1.0
class: Workflow
requirements:
  - class: ScatterFeatureRequirement
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
  input_bam:
    type:
    - type: array
      items: [string, File] 
    secondaryFiles:
      - .bai
  dbsnp:
    type: ["null", string, "File"]
    secondaryFiles:
      - .tbi
  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
  interval:
    type: ["null", string, File]
  output_file:
    type: string

  shard:
    type: string[]

  min_base_qual:
    type: ["null", int]

  normal_sample:
    type: ["null", string]

  tumor_sample:
    type: ["null", string]

  detect_pon:
    type: ["null", boolean]

  pon_sample:
    type: ["null", string]

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


  min_tumor_lod:
    type: ["null", double]

  min_normal_lod:
    type: ["null", double]

  min_dbsnp_normal_lod:
    type: ["null", double]

  contamination_frac:
    type: ["null", double]

  min_cell_mutation_frac:
    type: ["null", double]

  min_strand_bias_lod:
    type: ["null", double]

  min_strand_bias_power:
    type: ["null", double]

  min_normal_allele_frac:
    type: ["null", double]

  min_tumor_allele_frac:
    type: ["null", double]

  max_indel:
    type: ["null", int]

  max_read_clip_frac:
    type: ["null", double]

  max_mapq0_frac:
    type: ["null", double]

  min_pir_median:
    type: ["null", double]

  min_pir_mad:
    type: ["null", double]

  max_alt_mapq:
    type: ["null", double]
  
  max_normal_alt_cnt:
    type: ["null", int]

  max_normal_alt_qsum:
    type: ["null", int]

  max_normal_alt_frac:
    type: ["null", double]

  power_allele_frac:
    type: ["null", double]

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string

outputs:
  output:
    type: File
    outputSource: merge/output
    secondaryFiles:
      - .tbi

steps:
  tnsnv:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      dbsnp: dbsnp
      normal_sample: normal_sample
      tumor_sample: tumor_sample
      cosmic: cosmic
      pon: pon
      detect_pon: detect_pon
      pon_sample: pon_sample
      min_init_tumor_lod: min_init_tumor_lod
      min_tumor_lod: min_tumor_lod
      contamination_frac: contamination_frac
      min_cell_mutation_frac: min_cell_mutation_frac
      min_normal_lod: min_normal_lod
      min_strand_bias_lod: min_strand_bias_lod
      min_strand_bias_power: min_strand_bias_power
      min_dbsnp_normal_lod: min_dbsnp_normal_lod
      min_normal_allele_frac: min_normal_allele_frac
      min_tumor_allele_frac: min_tumor_allele_frac
      min_base_qual: min_base_qual
      max_indel: max_indel
      max_read_clip_frac: max_read_clip_frac
      max_mapq0_frac: max_mapq0_frac
      min_pir_median: min_pir_median
      min_pir_mad: min_pir_mad
      max_alt_mapq: max_alt_mapq
      max_normal_alt_cnt: max_normal_alt_cnt
      max_normal_alt_qsum: max_normal_alt_qsum
      max_normal_alt_frac: max_normal_alt_frac
      power_allele_frac: power_allele_frac          
      interval: interval
      shard: shard
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      output_file:
        source: shard
        linkMerge: merge_flattened
        valueFrom: |
          ${
            var len = inputs._shard.length;
            var i = 0;
            for (; i < len; ++i) {
               if (self == inputs._shard[i])
                 break;
            }
            return inputs._output + "_part_" + i + "." + inputs._output.split(".").pop();
          }
      advanced_options: advanced_options
    out: [output]
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    run: ../algo/tnsnv.cwl

  merge:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: tnsnv/output
      output_file: output_file
    out: [output]
    run: ../algo/tnsnv.cwl



