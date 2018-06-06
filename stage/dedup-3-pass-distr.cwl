cwlVersion: v1.0
class: Workflow
doc: "run 3-pass dedup: algo LocusCollector + algo Dedup output_dup_read_name + algo Dedup dedup_by_read_name sequentially in distributed mode"
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
  metrics_output_file:
    type: string
  output_file:
    type: string
  interval:
    type: ["null", string, File]
  threads:
    type: ["null", int]
  shard:
    type: string[]
  advanced_options:
    type:
    - "null"
    - type: record
      fields:
        - name: dedup_pre
          type:
          - "null"
          - type: array
            items: string
        - name: dedup
          type:
          - "null"
          - type: array
            items: string

outputs:
  output:
    type: File
    outputSource: merge/output
  metrics_output:
    type: ["null", File]
    outputSource: merge_metrics/output

steps:
  dedup_pre:
    in:
      input_bam: input_bam
      reference: reference
      shard: shard
      threads: threads
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      _ext: {"default": ".score.gz"}
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
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup_pre : []; }
    out: [output]
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    run: ../algo/dedup_pre.cwl

  dup_read_name:
    in:
      input_bam: input_bam
      reference: reference
      shard: shard
      threads: threads
      interval: interval
      score_info:
        source: dedup_pre/output
      output_dup_read_name: 
        valueFrom: ${ return true; }
      _output: output_file # to provide base name for output_file
      _shard: shard # to deriver shard index
      _metrics_ext: {"default": ".dedup_metrics_output_file.txt"}
      _ext: {"default": ".dup_read_name.gz"}
      metrics:
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
            return inputs._output + "_part_" + i + inputs._metrics_ext;
          }
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
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup : []; }
    scatter: [shard, metrics, output_file]
    scatterMethod: dotproduct    
    out: [output, metrics_output]
    run: ../algo/dedup.cwl

  dedup_by_read_name:
    in:
      input_bam: input_bam
      reference: reference
      shard: shard
      threads: threads
      interval: interval
      dup_read_name: 
        source: dup_read_name/output
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
      advanced_options:
        source: advanced_options
        valueFrom: |
          ${ return self ? self.dedup : []; }
    scatter: [shard, output_file]
    scatterMethod: dotproduct
    out: [output]
    run: ../algo/dedup.cwl

  merge:
    in:
      threads: threads
      input_bam:
        source: dedup_by_read_name/output
      output_file: output_file
    out: [output]
    run: ../algo/bam-merge.cwl

  merge_metrics:
    in:
      threads: threads
      part_metrics:
        source: dup_read_name/metrics_output
      output_file: metrics_output_file
      merge:
        valueFrom: ${ return true; } 
      rmdup: 
        valueFrom: ${ return false; } 
    out: [output]
    run: ../algo/dedup.cwl

    


