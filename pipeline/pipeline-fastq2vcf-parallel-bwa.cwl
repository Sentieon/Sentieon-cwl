cwlVersion: v1.0
class: Workflow
doc: "DNAseq pipeline from fastq to vcf"
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
    type: string?
    default: library
  platform:
    type: string?
    default: ILLUMINA
  mark_secondary:
    type: boolean?
  chunk_size:
    type: int?
  bwa_output_bam:
    type: string

  dedup_output_bam:
    type: string
  dedup_metrics_output_file:
    type: string
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
  realign_output_bam:
    type: string
  qcal_output_file:
    type: string
  dbsnp:
    type: ["null", string, File]
    secondaryFiles:
      - .tbi
  output_file:
    type: string
  interval:
    type: ["null", string, File]
  threads:
    type: ["null", int]

outputs:
  bwa_output:
    type: File
    outputSource: bam_merge/output
  dedup_output:
    type: File
    outputSource: dedup/output
  dedup_metrics_output:
    type: ["null", File]
    outputSource: dedup/metrics_output
  realign_output:
    type: File
    outputSource: realign/output  
  qcal_output:
    type: File
    outputSource: bqsr/qcal_output
  qcal_plot_output:
    type: ["null", File]
    outputSource: bqsr/plot_output
  qcal_plot_csv_output:
    type: ["null", File]
    outputSource: bqsr/plot_csv_output
  output:
    type: File
    outputSource: hc/output    

steps:
  bwa:
    in:
      reference: reference
      reads: input_reads
      mark_secondary: mark_secondary
      chunk_size: chunk_size
      output_file: 
        source: bwa_output_bam
        valueFrom: |
          ${
            var ext = self.split(".").pop();
            return self + "_" + inputs._readgroup + "_" + inputs._sample + "." + ext;
          }
      threads: threads
      sort_threads: threads
      _readgroup: readgroup
      _sample: sample
      _platform: platform
      _library: library
      readgroup:
        valueFrom: |
          ${
            var rg = "@RG\tID:" + inputs._readgroup + "\tSM:" + inputs._sample
                     + "\tPL:" + inputs._platform;
            if ( inputs._library != null ) rg += "\tLB:" + inputs._library;
            return rg;
          }
    out: [output]
    scatter: [_readgroup, _sample, reads]
    scatterMethod: dotproduct
    run: ../algo/bwa-mem-sort.cwl
  bam_merge:
    in:
      reference: reference
      input_bam: bwa/output
      mergemode:
        valueFrom: ${ return 0; }
      output_file: bwa_output_bam
      threads: threads
    out: [output]
    run: ../algo/bam-merge.cwl
  dedup:
    in:
      reference: reference
      input_bam: 
        source: bam_merge/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      metrics_output_file: dedup_metrics_output_file
      output_file: dedup_output_bam
      threads: threads
      interval: interval
    out: [output, metrics_output]      
    run: ../stage/dedup-2-pass.cwl
  realign:
    in:
      reference: reference
      input_bam: 
        source: dedup/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: realign_known_sites
      output_file: realign_output_bam
      threads: threads
      interval_list: interval
    out: [output]
    run: ../algo/realign.cwl
  bqsr:
    in:
      reference: reference
      input_bam: 
        source: realign/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      known_sites: bqsr_known_sites
      output_file: qcal_output_file
      plot_output_file:
        source: qcal_output_file
        valueFrom: ${ return self + ".pdf"; }
      plot_output_csv_file:
        source: qcal_output_file
        valueFrom: ${ return self + ".csv"; }
      threads: threads
      interval: interval
    out: [qcal_output, plot_output, plot_csv_output]
    run: ../stage/bqsr-flow.cwl
  hc:
    in:
      reference: reference
      input_bam: 
        source: realign/output
        valueFrom: ${ return [ self ]; } # convert one element to array
      dbsnp: dbsnp
      output_file: output_file
      qcal: 
        source: bqsr/qcal_output
        valueFrom: ${ return [ self ]; } # convert one element to array
      threads: threads
      interval: interval
    out: [output]
    run: ../algo/hc.cwl


