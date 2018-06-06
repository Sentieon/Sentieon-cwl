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
  interval:
    type: ["null", string, File]
  output_file:
    type: string
  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
  
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
  bqsr:
    in:
      input_bam: input_bam
      reference: reference
      known_sites: known_sites
      interval: interval
      qcal: qcal
      shard: shard
      threads: threads 
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      _ext: {"default":".table"}
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
    run: ../algo/bqsr.cwl

  merge:
    in:
      threads: threads 
      merge:
        valueFrom: ${ return true; }
      part_output: bqsr/output
      output_file: output_file
    out: [output]
    run: ../algo/bqsr.cwl


