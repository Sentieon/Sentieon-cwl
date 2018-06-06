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
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  interval:
    type: ["null", string, File]

  input_vcf:
    type:
    - "null"
    - type: array
      items: [string, File]
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

  max_alt_alleles:
    type: ["null", int]

  output_file:
    type: string

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
    inputBinding:
      position: 110    
   
outputs:
  output:
    type: File
    outputSource: merge/output

steps:
  hc:
    in:
      reference: reference
      threads: threads
      dbsnp: dbsnp
      interval: interval
      input_vcf: input_vcf
      annotation: annotation
      call_conf: call_conf
      emit_conf: emit_conf
      emit_mode: emit_mode
      max_alt_alleles: max_alt_alleles
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
    run: ../algo/gvcf.cwl

  merge:
    in:
      threads: threads
      merge:
        valueFrom: ${ return true; }
      part_output: hc/output
      output_file: output_file
    out: [output]
    run: ../algo/gvcf.cwl


