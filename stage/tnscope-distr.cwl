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

  given:
    type: ["null", File]
    secondaryFiles:
      - .tbi

  pcr_indel_model:
    type: ["null", string]

  min_base_qual:
    type: ["null", int]

  phasing:
    type: ["null", int]

  prune_factor:
    type: ["null", int]

  normal_sample:
    type: ["null", string]

  tumor_sample:
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

  sv_mask_ext:
    type: ["null", int]

  sv_mask_cmd:
    type: ["null", string]

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
    outputSource: sv_solver/output
    secondaryFiles:
      - .tbi

steps:
  tnscope:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      dbsnp: dbsnp
      given: given
      pcr_indel_model: pcr_indel_model
      min_base_qual: min_base_qual
      phasing: phasing
      prune_factor: prune_factor
      normal_sample: normal_sample
      tumor_sample: tumor_sample
      cosmic: cosmic
      pon: pon
      min_init_tumor_lod: min_init_tumor_lod
      min_init_normal_lod: min_init_normal_lod
      min_tumor_lod: min_tumor_lod
      min_normal_lod: min_normal_lod
      min_dbsnp_normal_lod: min_dbsnp_normal_lod
      tumor_contamination_frac: tumor_contamination_frac
      normal_contamination_frac: normal_contamination_frac
      sv_mask_ext: sv_mask_ext
      sv_mask_cmd: sv_mask_cmd
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
            return inputs._output + ".pre_part_" + i + ".vcf.gz";
          }
      sv_data_tmp_output_file:
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
            return inputs._output + ".sv_data_tmp_part_" + i + ".vcf.gz";
          }
      sv_mate_tmp_output_file:
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
            return inputs._output + ".sv_mate_tmp_part_" + i + ".vcf.gz";
          }
      advanced_options: advanced_options
    out: [output, sv_data_tmp_output, sv_mate_tmp_output]
    scatter: [shard, output_file, sv_data_tmp_output_file, sv_mate_tmp_output_file]
    scatterMethod: dotproduct
    run: ../algo/tnscope.cwl

  merge_pre_output:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: tnscope/output
      output_file:
        source: output_file
        valueFrom: $(self).pre_output.vcf.gz
    out: [output]
    run: ../algo/tnscope.cwl

  merge_sv_data_tmp_output:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      merge_sv_data:
        valueFrom: ${ return true; }
      part_output: tnscope/sv_data_tmp_output
      output_file:
        source: output_file
        valueFrom: $(self).sv_data_tmp.vcf.gz
    out: [output]
    run: ../algo/tnscope.cwl

  merge_sv_mate_tmp_output:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      merge_sv_mate:
        valueFrom: ${ return true; }
      part_output: tnscope/sv_mate_tmp_output
      output_file:
        source: output_file
        valueFrom: $(self).sv_mate_tmp.vcf.gz
    out: [output]
    run: ../algo/tnscope.cwl

  sv_solver:
    in:
      reference: reference
      input_bam: input_bam
      dbsnp: dbsnp
      given: given
      pcr_indel_model: pcr_indel_model
      min_base_qual: min_base_qual
      phasing: phasing
      prune_factor: prune_factor
      normal_sample: normal_sample
      tumor_sample: tumor_sample
      cosmic: cosmic
      pon: pon
      min_init_tumor_lod: min_init_tumor_lod
      min_init_normal_lod: min_init_normal_lod
      min_tumor_lod: min_tumor_lod
      min_normal_lod: min_normal_lod
      min_dbsnp_normal_lod: min_dbsnp_normal_lod
      tumor_contamination_frac: tumor_contamination_frac
      normal_contamination_frac: normal_contamination_frac
      sv_mask_ext: sv_mask_ext
      sv_mask_cmd: sv_mask_cmd
      sv_solver:
        valueFrom: ${ return true; }
      pre_output: merge_pre_output/output
      sv_data_tmp_file: merge_sv_data_tmp_output/output
      sv_mate_tmp_file: merge_sv_mate_tmp_output/output
      output_file: output_file
    out: [output]
    run: ../algo/tnscope.cwl
  

