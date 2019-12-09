workflow trnascan {

  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  String output_dir 
  Int    additional_threads
  File   trnascan_se_bin
  File   pick_and_transform_to_gff_bin

  call trnascan_ba {
    input:
      bin = trnascan_se_bin,
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      threads = additional_threads,
      out_dir = output_dir
  }
  call pick_and_transform_to_gff {
    input:
      bin = pick_and_transform_to_gff_bin,
      project_id = imgap_project_id,
      bacterial_out = trnascan_ba.bacterial_out,
      archaeal_out = trnascan_ba.archaeal_out
  }
  output {
    File gff = pick_and_transform_to_gff.gff
  }
}

task trnascan_ba {

  File   bin
  String input_fasta
  String project_id
  String out_dir
  Int    threads

  command {
    ${bin} -B --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_bacterial.out
    ${bin} -A --thread ${threads} ${input_fasta} &> ${project_id}_trnascan_archaeal.out
    cp -r ./${project_id}_trnascan_*.out ${out_dir}
  }
  output {
    File bacterial_out = "${project_id}_trnascan_bacterial.out"
    File archaeal_out = "${project_id}_trnascan_archaeal.out"
  }
}

task pick_and_transform_to_gff {

  File   bin
  String project_id
  File   bacterial_out
  File   archaeal_out
  
  command {
    ${bin} ${bacterial_out} ${archaeal_out} > ${project_id}_trna.gff
  }
  output {
    File gff = "${project_id}_trna.gff"
  }
}
