cwlVersion: v1.0
class: CommandLineTool
baseCommand: [sentieon, driver]
requirements:
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: $(inputs.threads)

inputs:
  reference:
    type: ["null", string, File]
    inputBinding:
      position: 10
      prefix: -r
    secondaryFiles:
      - .fai

  input_bam:
    type:
    - File
    - type: array
      items: [string, File]
      inputBinding:     
        prefix: -i
    inputBinding:     
      position: 10 
    secondaryFiles:
      - .bai

  qcal:
    type:
    - "null"
    - type: array
      items: [string, File]
      inputBinding:
        prefix: -q
        position: 10

  interval:
    type: ["null", string, File]
    inputBinding:
      prefix: --interval
      position: 10

  shard:
    type: ["null", string]
    inputBinding:
      prefix: --shard
      position: 10

  threads:
    type: ["null", int]
    inputBinding:
      prefix: -t
      position: 10    

 # algo starts with big position 100
  algo:
    type: string
    inputBinding:
      position: 100
      prefix: --algo
  output_file:
    type: string
    inputBinding:
      position: 150

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
    outputBinding:
      glob: $(inputs.output_file)
    secondaryFiles:
      - ${
          var f = self.basename;
          var ext = f.split(".").pop();
          if (ext == "bam") return f + ".bai";
          else if (ext == "cram") return f + ".crai";
          else if (ext == "gz") return f + ".tbi";
          else if (ext == "vcf") return f + ".idx";
          else return f; 
        }
  log:
    type: stderr
stderr: driver.log


