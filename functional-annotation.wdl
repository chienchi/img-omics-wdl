workflow f_annotate {

  String  imgap_project_id
  String  imgap_project_type
  Int     additional_threads
  String  output_dir
  File?    input_contigs_fasta
  File    input_fasta
  Boolean ko_ec_execute
  String  ko_ec_img_nr_db
  File    ko_ec_md5_mapping
  File    ko_ec_taxon_to_phylo_mapping
  String  lastal_bin
  String  selector_bin
  Boolean smart_execute
  Int?    par_hmm_inst
  Int?    approx_num_proteins
  File    smart_db
  String  hmmsearch_bin
  String  frag_hits_filter_bin
  Boolean cog_execute
  File    cog_db
  Boolean tigrfam_execute
  File    tigrfam_db
  String  hit_selector_bin
  Boolean superfam_execute
  File    superfam_db
  Boolean pfam_execute
  File    pfam_db
  File    pfam_claninfo_tsv
  String  pfam_clan_filter
  Boolean cath_funfam_execute
  File    cath_funfam_db
  Boolean signalp_execute
  String  signalp_gram_stain
  String  signalp_bin
  Boolean tmhmm_execute
  String  tmhmm_model
  String  tmhmm_decode
  String  tmhmm_decode_parser
  File    sa_gff
  String  product_assign_bin
  String  product_names_mapping_dir

  call getz{
       input: contigs=input_contigs_fasta
  }
  
  if(ko_ec_execute) {
    call ko_ec {
      input:
        project_id = imgap_project_id,
        project_type = imgap_project_type,
        input_fasta = input_fasta,
        threads = additional_threads,
        nr_db = ko_ec_img_nr_db,
        md5 = ko_ec_md5_mapping,
        phylo = ko_ec_taxon_to_phylo_mapping,
        lastal = lastal_bin,
        selector = selector_bin,
        out_dir = output_dir
    }
  }
  if(smart_execute) {
    call smart {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        smart_db = smart_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin,
        out_dir = output_dir
    }
  }
  if(cog_execute) {
    call cog {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        cog_db = cog_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin,
        out_dir = output_dir
    }
  }
  if(tigrfam_execute) {
    call tigrfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        tigrfam_db = tigrfam_db,
        hmmsearch = hmmsearch_bin,
        hit_selector = hit_selector_bin,
        out_dir = output_dir
    }
  }
  if(superfam_execute) {
    call superfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        superfam_db = superfam_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin,
        out_dir = output_dir
    }
  }
  if(pfam_execute) {
    call pfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        pfam_db = pfam_db,
        pfam_claninfo_tsv = pfam_claninfo_tsv,
        pfam_clan_filter = pfam_clan_filter,
        hmmsearch = hmmsearch_bin,
        out_dir = output_dir
    }
  }
  if(cath_funfam_execute) {
    call cath_funfam {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        threads = additional_threads,
        par_hmm_inst = par_hmm_inst,
        approx_num_proteins = getz.out,
        cath_funfam_db = cath_funfam_db,
        hmmsearch = hmmsearch_bin,
        frag_hits_filter = frag_hits_filter_bin,
        out_dir = output_dir
    }
  }
  if(imgap_project_type == "isolate" && signalp_execute) {
    call signalp {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        gram_stain = signalp_gram_stain,
        signalp = signalp_bin,
        out_dir = output_dir
    }
  }
  if(imgap_project_type == "isolate" && tmhmm_execute) {
    call tmhmm {
      input:
        project_id = imgap_project_id,
        input_fasta = input_fasta,
        model = tmhmm_model,
        decode = tmhmm_decode,
        decode_parser = tmhmm_decode_parser,
        out_dir = output_dir
    }
  }
if(true){
  call product_name {
    input:
      project_id = imgap_project_id,
      sa_gff = sa_gff,
      product_assign = product_assign_bin,
      map_dir = product_names_mapping_dir,
      ko_ec_gff = ko_ec.gff,
      smart_gff = smart.gff,
      cog_gff = cog.gff,
      tigrfam_gff = tigrfam.gff,
      supfam_gff = superfam.gff,
      pfam_gff = pfam.gff,
      cath_funfam_gff = cath_funfam.gff,
      signalp_gff = signalp.gff,
      tmhmm_gff = tmhmm.gff,
      out_dir = output_dir
  }
}
}

task getz {
     File? contigs
     String contigs_provided = if(defined(contigs)) then "1" else "0"
     String dollar="$"
     command {
          if [[ ${contigs_provided} == 1 ]]
          then
             echo ${dollar}(egrep -v "^>" ${contigs} | tr -d '\n' | wc -m) / 500 | bc;
          else
             echo 0;
          fi
    }
    output {
        String out = read_string(stdout())
    }
}

task ko_ec {

  String project_id
  String project_type
  Int    threads = 2
  File   input_fasta
  String nr_db
  File   md5
  File   phylo
  Int    top_hits = 5
  Int    min_ko_hits = 2
  Float  aln_length_ratio = 0.7
  String lastal
  String selector
  String out_dir

  command {
    ${lastal} -f blasttab+ -P ${threads} ${nr_db} ${input_fasta} 1> ${project_id}_proteins.img_nr.last.blasttab
    ${selector} -l ${aln_length_ratio} -m ${min_ko_hits} -n ${top_hits} \
                ${project_type} ${md5} ${phylo} \
                ${project_id}_ko.tsv ${project_id}_ec.tsv \
                ${project_id}_gene_phylogeny.tsv ${project_id}_ko_ec.gff \
                < ${project_id}_proteins.img_nr.last.blasttab
    #cp ${project_id}_*.tsv ${project_id}_ko_ec.gff ${project_id}_proteins.img_nr.last.blasttab ${out_dir}
  }

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File last_blasttab = "${project_id}_proteins.img_nr.last.blasttab"
    File ko_tsv = "${project_id}_ko.tsv"
    File ec_tsv = "${project_id}_ec.tsv"
    File phylo_tsv = "${project_id}_gene_phylogeny.tsv"
    File gff = "${project_id}_ko_ec.gff"
  }
}

task smart {
  
  String project_id
  File   input_fasta
  File   smart_db
  Int    threads = 62
  Int    par_hmm_inst = 15
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
     /opt/omics/bin/functional_annotation/hmmsearch_smart.sh ${dollar}base \
     ${smart_db} \
     ${threads} ${par_hmm_inst} ${approx_num_proteins} \
     ${min_domain_eval_cutoff} ${aln_length_ratio} ${max_overlap_ratio} 
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_smart.gff"
	File domtblout = "${project_id}_proteins.smart.domtblout"
  }
}

task cog {
  
  String project_id
  File   input_fasta
  File   cog_db
  Int    threads = 62
  Int    par_hmm_inst = 15
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
     /opt/omics/bin/functional_annotation/hmmsearch_cogs.sh ${dollar}base \
     ${cog_db} \
     ${threads} ${par_hmm_inst} ${approx_num_proteins} \
     ${min_domain_eval_cutoff} ${aln_length_ratio} ${max_overlap_ratio} 
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_cog.gff"
	File domtblout = "${project_id}_proteins.cog.domtblout"
  }
}

task tigrfam {
  
  String project_id
  File   input_fasta
  File   tigrfam_db
  Int    threads = 62
  Int    par_hmm_inst = 15
  Int    approx_num_proteins = 0
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String hit_selector
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
     /opt/omics/bin/functional_annotation/hmmsearch_tigrfams.sh ${dollar}base \
     ${tigrfam_db} \
     ${threads} ${par_hmm_inst} ${approx_num_proteins} \
     ${aln_length_ratio} ${max_overlap_ratio} 
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_tigrfam.gff"
	File domtblout = "${project_id}_proteins.tigrfam.domtblout"
  }
}

task superfam {

  String project_id
  File   input_fasta
  File   superfam_db
  Int    threads = 62
  Int    par_hmm_inst = 15
  Int    approx_num_proteins = 0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
    #Usage: hmmsearch_supfams.sh <proteins_fasta> <supfam_hmm_db> <number_of_additional_threads (default: 0)> <number_of_parallel_hmmsearch_instances (default: 0)> <approximate_number_of_total_proteins (default: 0)> <min_domain_evalue_cutoff (default 0.01)> <min_aln_length_ratio (default 0.7)> <max_overlap_ratio (default 0.1)> 

     /opt/omics/bin/functional_annotation/hmmsearch_supfams.sh ${dollar}base \
     ${superfam_db} \
     ${threads} ${par_hmm_inst} ${approx_num_proteins} \
     ${min_domain_eval_cutoff} ${aln_length_ratio} ${max_overlap_ratio} 
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_supfam.gff"
	File domtblout = "${project_id}_proteins.supfam.domtblout"
  }
}

task pfam {
  String project_id
  File   input_fasta
  File   pfam_db
  File   pfam_claninfo_tsv
  Int    threads = 62
  Int    par_hmm_inst = 15
  Int    approx_num_proteins = 0
  String hmmsearch
  String pfam_clan_filter
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
     
    #Usage: hmmsearch_pfams.sh <proteins_fasta> <pfam_hmm_db> <pfam_claninfo_tsv> <number_of_additional_threads (default: 0)>
     /opt/omics/bin/functional_annotation/hmmsearch_pfams.sh ${dollar}base \
     ${pfam_db} ${pfam_claninfo_tsv} \
     ${threads} ${par_hmm_inst} ${approx_num_proteins}
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_pfam.gff"
	File domtblout = "${project_id}_proteins.pfam.domtblout"
  }
}

task cath_funfam {
 
  String project_id
  File   input_fasta
  File   cath_funfam_db
  Int    threads=62
  Int    par_hmm_inst=15
  Int    approx_num_proteins=0
  Float  min_domain_eval_cutoff = 0.01
  Float  aln_length_ratio = 0.7
  Float  max_overlap_ratio = 0.1
  String hmmsearch
  String frag_hits_filter
  String out_dir
  String dollar="$"
  command <<<
     base=${dollar}(basename ${input_fasta})
     cp ${input_fasta} ${dollar}base
     /opt/omics/bin/functional_annotation/hmmsearch_cath_funfams.sh  ${dollar}base \
     ${cath_funfam_db} ${threads} ${par_hmm_inst} ${approx_num_proteins} \
     ${min_domain_eval_cutoff} ${aln_length_ratio} ${max_overlap_ratio} 
  >>>
  
  output {
      File gff = "${project_id}_cath_funfam.gff"
      File domtblout = "${project_id}_proteins.cath_funfam.domtblout"
  }
}

task signalp {
  
  String project_id
  File   input_fasta
  String gram_stain
  String signalp
  String out_dir

  command <<<
    signalp_version=$(${signalp} -V)
    ${signalp} -t ${gram_stain} -f short ${input_fasta} | \
    grep -v '^#' | \
    awk -v sv="$signalp_version" -v ot="${gram_stain}" \
        '$10 == "Y" {print $1"\t"sv"\tcleavage_site\t"$3-1"\t"$3"\t"$2\
        "\t.\t.\tD-score="$9";network="$12";organism_type="ot}' > ${project_id}_cleavage_sites.gff
    #cp ./${project_id}_cleavage_sites.gff ${out_dir}
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_cleavage_sites.gff"
  }
}

task tmhmm {
  
  String project_id
  File   input_fasta
  String model
  String decode
  String decode_parser
  String out_dir

  command <<<
    tool_and_version=$(${decode} -v 2>&1 | head -1)
    background="0.081 0.015 0.054 0.061 0.040 0.068 0.022 0.057 0.056 0.093 0.025"
    background="$background 0.045 0.049 0.039 0.057 0.068 0.058 0.067 0.013 0.032"
    sed 's/\*/X/g' ${input_fasta} | \
    ${decode} -N 1 -background $background -PrintNumbers \
    ${model} 2> /dev/null | ${decode_parser} "$tool_and_version" > ${project_id}_tmh.gff
    #cp ./${project_id}_tmh.gff ${out_dir}
  >>>

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_tmh.gff"
  }
}

task product_name {
  
  String project_id
  File   sa_gff
  String product_assign
  String map_dir
  File?  ko_ec_gff
  File?  smart_gff
  File?  cog_gff
  File?  tigrfam_gff
  File?  supfam_gff
  File?  pfam_gff
  File?  cath_funfam_gff
  File?  signalp_gff
  File?  tmhmm_gff
  String out_dir

  command {
    ${product_assign} ${"-k " + ko_ec_gff} ${"-s " + smart_gff} ${"-c " + cog_gff} \
                      ${"-t " + tigrfam_gff} ${"-u " + supfam_gff} ${"-p " + pfam_gff} \
                      ${"-f " + cath_funfam_gff} ${"-e " + signalp_gff} ${"-r " + tmhmm_gff} \
                      ${map_dir} ${sa_gff}
    mv ../inputs/*/*.gff .
    #cp ./${project_id}_functional_annotation.gff ${out_dir}
  }

  runtime {
    cluster: "cori"
    time: "1:00:00"
    mem: "86G"
    poolname: "justtest"
    shared: 1
    node: 1
    nwpn: 1
    constraint: "haswell"
  }

  output {
    File gff = "${project_id}_functional_annotation.gff"
  }
}
