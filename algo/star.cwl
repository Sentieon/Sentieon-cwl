#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  genome_dir:
    type: string
    inputBinding:
      position: 3
      prefix: --genomeDir
      
  reads:
    type:
      type: array
      items: [string, File]
    inputBinding:
      position: 3
      prefix: --readFilesIn
  
  read_command:
    type: string
    default: "zcat"
    inputBinding:
      position: 10
      prefix: --readFilesCommand
      
  threads:
    type: int?
    inputBinding:
      position: 10
      prefix: --runThreadN

  mode:
    type: string
    default: "Basic"
    inputBinding:
      position: 10
      prefix: --twopassMode

  advanced_options:
    type: 
    - "null"
    - type: array
      items: string
    inputBinding:
      position: 100

outputs:
  output:
    type: File
    outputBinding:
      glob: "Aligned.sortedByCoord.out.bam"
  log:
    type: stderr
stderr: star.log

baseCommand: /home/release/other_tools/STAR/bin/Linux_x86_64_static/STAR

  



