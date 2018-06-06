cwlVersion: v1.0
class: Workflow
doc: "run scatter-gather for rw stage"
requirements:
  - class: ScatterFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    secondaryFiles:
      - .fai
  input_bam:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .bai
  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
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
  rw:
    in:
      input_bam: input_bam
      qcal: qcal
      reference: reference
      threads: threads
      advanced_options: advanced_options
      shard: shard
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      _ext: {"default": ".bam"}
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
    out: [output]
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    run: ../algo/rw.cwl
  merge:
    in:
      threads: threads
      input_bam:
        source: rw/output
      output_file: output_file
    out: [output]
    run: ../algo/bam-merge.cwl


