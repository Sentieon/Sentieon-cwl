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
  known_sites:
    type:
    - "null"
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  interval_list:
    type: ["null", File]
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
  realign:
    in:
      input_bam: input_bam
      reference: reference
      threads: threads
      known_sites: known_sites
      interval_list: interval_list
      shard: shard
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      _ext: {"default":".bam"}
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
            return inputs._output + "_part_" + i + inputs._ext;
          }
      advanced_options: advanced_options
    out: [output]
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    run: ../algo/realign.cwl

  merge:
    in:
      threads: threads
      input_bam:
        source: realign/output
      output_file: output_file
    out: [output]
    run: ../algo/bam-merge.cwl


