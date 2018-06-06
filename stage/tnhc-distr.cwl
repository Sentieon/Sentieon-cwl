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
    type: ["null", string, File]
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

  pcr_indel_model:
    type: ["null", string]

  phasing:
    type: ["null", int]

  prune_factor:
    type: ["null", int]

  min_base_qual:
    type: ["null", int]

  normal_sample:
    type: ["null", string]

  tumor_sample:
    type: ["null", string]

  detect_pon:
    type: ["null", boolean]

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

  min_init_normal_lod:
    type: ["null", double]

  min_tumor_lod:
    type: ["null", double]

  min_normal_lod:
    type: ["null", double]

  min_dbsnp_normal_lod:
    type: ["null", double]

  tumor_contamination_frac:
    type: ["null", double]

  normal_contamination_frac:
    type: ["null", double]

  filter_clustered_read_position:
    type: ["null", int]

  filter_strand_bias:
    type: ["null", int]

  min_strand_bias_lod:
    type: ["null", double]

  min_strand_bias_power:
    type: ["null", double]

  min_pir_median:
    type: ["null", double]

  min_pir_mad:
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
  tnhc:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      dbsnp: dbsnp      
      min_base_qual: min_base_qual
      pcr_indel_model: pcr_indel_model
      phasing: phasing
      prune_factor: prune_factor
      normal_sample: normal_sample
      tumor_sample: tumor_sample
      cosmic: cosmic
      pon: pon
      detect_pon: detect_pon
      min_init_tumor_lod: min_init_tumor_lod
      min_init_normal_lod: min_init_normal_lod
      min_tumor_lod: min_tumor_lod
      min_normal_lod: min_normal_lod
      min_dbsnp_normal_lod: min_dbsnp_normal_lod
      tumor_contamination_frac: tumor_contamination_frac
      normal_contamination_frac: normal_contamination_frac
      filter_clustered_read_position: filter_clustered_read_position
      min_pir_median: min_pir_median
      min_pir_mad: min_pir_mad
      filter_strand_bias: filter_strand_bias
      min_strand_bias_lod: min_strand_bias_lod
      min_strand_bias_power: min_strand_bias_power
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
    run: ../algo/tnhc.cwl

  merge:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: tnhc/output
      output_file: output_file
    out: [output]
    run: ../algo/tnhc.cwl



