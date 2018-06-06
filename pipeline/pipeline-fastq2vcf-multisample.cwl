cwlVersion: v1.0
class: Workflow
doc: "DNAseq pipeline from fastq to vcf for multiple samples"
requirements:
  - class: MultipleInputFeatureRequirement
  - class: StepInputExpressionRequirement
  - class: InlineJavascriptRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: [string, File]
    secondaryFiles:
      - .fai
      - .bwt
      - .sa
      - .ann
      - .amb
      - .pac
  input_reads:
    type:
    - type: array
      items:
      - type: array
        items: [string, File]
  readgroup:
    type: string[]
  sample:
    type: string[]
  library:
    type: string[]
  platform:
    type: string?
    default: ILLUMINA 
  realign_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  bqsr_known_sites:
    type:
    - type: array
      items: [string, File]
    secondaryFiles:
      - .tbi
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  mark_secondary:
    type: boolean?
  chunk_size:
    type: int?
  interval:
    type: ["null", string, File]
  threads:
    type: ["null", int]

outputs:
  bwa_output:
    type: File[]
    outputSource: pipeline/bwa_output
  dedup_output:
    type: File[]
    outputSource: pipeline/dedup_output
  dedup_metric_output:
    type: File[]?
    outputSource: pipeline/dedup_metrics_output
  realign_output:
    type: File[]
    outputSource: pipeline/realign_output  
  qcal_output:
    type: File[]
    outputSource: pipeline/qcal_output
  qcal_plot_output:
    type: File[]?
    outputSource: pipeline/qcal_plot_output
  output:
    type: File[]
    outputSource: pipeline/output

steps:
  pipeline:
    in:
      reference: reference
      input_reads: input_reads
      readgroup: readgroup
      sample: sample
      library: library
      mark_secondary: mark_secondary
      chunk_size: chunk_size
      bqsr_known_sites: bqsr_known_sites
      realign_known_sites: realign_known_sites
      dbsnp: dbsnp
      threads: threads
      platform: platform
      qcal_output_file: 
        valueFrom: ${ return "recal_table_"+inputs.readgroup+"_"+inputs.sample; }
      bwa_output_bam: 
        valueFrom: ${ return "sorted_"+inputs.readgroup+"_"+inputs.sample+".bam"; }
      dedup_output_bam: 
        valueFrom: ${ return "deduped_"+inputs.readgroup+"_"+inputs.sample+".bam"; }
      dedup_metrics_output_file: 
        valueFrom: ${ return "dedup-metrics_"+inputs.readgroup+"_"+inputs.sample+".txt"; }
      realign_output_bam: 
        valueFrom: ${ return "realigned_"+inputs.readgroup+"_"+inputs.sample+".bam"; }
      output_file:
        valueFrom: ${ return "output_"+inputs.readgroup+"_"+inputs.sample+".vcf.gz"; }
    out: [bwa_output, dedup_output, dedup_metrics_output, realign_output, qcal_output, qcal_plot_output, output]
    scatter: [readgroup, sample, library, input_reads]
    scatterMethod: dotproduct
    run: pipeline-fastq2vcf.cwl


