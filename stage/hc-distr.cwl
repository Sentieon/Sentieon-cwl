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

  given:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi

  annotation:
    type:
    - "null"
    - type: array
      items: string

  call_conf:
    type: ["null", double]

  emit_conf:
    type: ["null", double]

  emit_mode:
    type: ["null", string]

  gq_bands:
    type: ["null", string]

  pcr_indel_model:
    type: ["null", string]

  min_base_qual:
    type: ["null", int]

  phasing:
    type: ["null", int]

  ploidy:
    type: ["null", int]

  prune_factor:
    type: ["null", int]

  trim_soft_clip:
    type: ["null", boolean]
    default: false

  shard:
    type: string[]

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

steps:
  hc:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      dbsnp: dbsnp
      annotation: annotation
      call_conf: call_conf
      emit_conf: emit_conf
      emit_mode: emit_mode
      given: given
      gq_bands: gq_bands
      min_base_qual: min_base_qual
      pcr_indel_model: pcr_indel_model
      phasing: phasing
      ploidy: ploidy
      prune_factor: prune_factor
      trim_soft_clip: trim_soft_clip
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
    run: ../algo/hc.cwl

  merge:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: hc/output
      output_file: output_file
    out: [output]
    run: ../algo/hc.cwl


