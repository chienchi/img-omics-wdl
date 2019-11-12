workflow trnascan {

  Int    n
  String imgap_input_dir
  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  Int    additional_threads
  File   trnascan_se_bin

  call trnascan_se {
    input:
      bin = trnascan_se_bin,
      val = n,
      dir = imgap_input_dir,
      input_fasta = imgap_input_fasta,
      project_id = imgap_project_id,
      project_type = imgap_project_type,
      threads = additional_threads
  }
  output {
    File gff = trnascan_se.gff
  }
}

task test {
  Int val
  String dir
  String fasta

  command {
    head -n 5 ${dir}${val}/${fasta}
  }
}

task trnascan_se {

  File   bin
  Int    val
  String dir
  String input_fasta
  String project_id
  String project_type
  Int    threads

  command {
    ${bin} ${dir}${val}/${input_fasta} ${project_type} ${threads} &> ${project_id}_trna.log
  }
  output {
    File log = "${project_id}_trna.log"
    File gff = "${project_id}_trna.gff"
    File out = "${project_id}_trnascan_general.out"
  }
}
