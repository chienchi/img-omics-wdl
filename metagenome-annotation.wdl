import "structural-annotation.wdl" as sa
import "functional-annotation.wdl" as fa

workflow metagenome_annotation {

  Int    num_splits
  String imgap_input_dir
  String imgap_input_fasta
  String imgap_project_id
  String imgap_project_type
  Int additional_threads
  # structural annotation
  Boolean sa_execute
  Boolean sa_pre_qc_execute
  File    sa_pre_qc_bin
  String  sa_pre_qc_rename
  File    sa_post_qc_bin
  Boolean sa_trnascan_se_execute
  File    sa_trnascan_se_bin
  File    sa_trnascan_pick_and_transform_to_gff_bin
  Boolean sa_rfam_execute
  File    sa_rfam_cmsearch_bin
  File    sa_rfam_clan_filter_bin
  File    sa_rfam_cm
  File    sa_rfam_claninfo_tsv
  File    sa_rfam_feature_lookup_tsv
  Boolean sa_crt_execute
  File    sa_crt_cli_jar
  File    sa_crt_transform_bin
  Boolean sa_prodigal_execute
  File    sa_prodigal_bin
  File    sa_unify_bin
  Boolean sa_genemark_execute
  File    sa_genemark_iso_bin
  File    sa_genemark_meta_bin
  File    sa_genemark_meta_model
  File    sa_gff_merge_bin
  File    sa_fasta_merge_bin
  Boolean sa_gff_and_fasta_stats_execute
  File    sa_gff_and_fasta_stats_bin
  # functional annotation
  Boolean fa_execute
  String  fa_product_names_mapping_dir
  Boolean fa_ko_ec_execute
  File    fa_ko_ec_img_nr_db
  File    fa_ko_ec_md5_mapping
  File    fa_ko_ec_taxon_to_phylo_mapping
  File    fa_lastal_bin
  File    fa_selector_bin
  Boolean fa_cath_funfam_execute
  File    fa_cath_funfam_db
  Boolean fa_pfam_execute
  File    fa_pfam_db
  File    fa_pfam_claninfo_tsv
  Boolean fa_superfam_excute
  File    fa_superfam_db
  Boolean fa_cog_execute
  File    fa_cog_db
  Boolean fa_tigrfam_execute
  File    fa_tigrfam_db
  File    fa_hit_selector_bin
  Boolean fa_smart_execute
  File    fa_smart_db
  File    fa_hmmsearch_bin
  File    fa_frag_hits_filter_bin
  Boolean fa_signalp_execute
  String  fa_signalp_gram_stain
  Boolean fa_tmhmm_execute
  File    fa_tmhmm_model

  call setup {
    input:
      n_splits = num_splits,
      dir = imgap_input_dir,
      fasta = imgap_input_fasta
  }

  scatter(split in setup.splits) {

    if(sa_execute) {
      call sa.s_annotate {
        input:
          imgap_project_id = imgap_project_id,
          additional_threads = additional_threads,
          imgap_project_type = imgap_project_type,
          imgap_input_fasta = split,
          pre_qc_execute = sa_pre_qc_execute,
          pre_qc_bin = sa_pre_qc_bin,
          pre_qc_rename = sa_pre_qc_rename,
          post_qc_bin = sa_post_qc_bin,
          trnascan_se_execute = sa_trnascan_se_execute,
          trnascan_se_bin = sa_trnascan_se_bin,
          trnascan_pick_and_transform_to_gff_bin = sa_trnascan_pick_and_transform_to_gff_bin,
          rfam_execute = sa_rfam_execute,
          rfam_cmsearch_bin = sa_rfam_cmsearch_bin,
          rfam_clan_filter_bin = sa_rfam_clan_filter_bin,
          rfam_cm = sa_rfam_cm,
          rfam_claninfo_tsv = sa_rfam_claninfo_tsv,
          rfam_feature_lookup_tsv = sa_rfam_feature_lookup_tsv,
          crt_execute = sa_crt_execute,
          crt_cli_jar = sa_crt_cli_jar,
          crt_transform_bin = sa_crt_transform_bin,
          prodigal_execute = sa_prodigal_execute,
          prodigal_bin = sa_prodigal_bin,
          unify_bin = sa_unify_bin,
          genemark_execute = sa_genemark_execute,
          genemark_iso_bin = sa_genemark_iso_bin,
          genemark_meta_bin = sa_genemark_meta_bin,
          genemark_meta_model = sa_genemark_meta_model,
          gff_merge_bin = sa_gff_merge_bin,
          fasta_merge_bin = sa_fasta_merge_bin,
          gff_and_fasta_stats_execute = sa_gff_and_fasta_stats_execute,
          gff_and_fasta_stats_bin = sa_gff_and_fasta_stats_bin
      }
    }

    if(fa_execute) {
      call fa.f_annotate {
        input:
          imgap_project_id = imgap_project_id,
          imgap_project_type = imgap_project_type,
          additional_threads = additional_threads,
          input_fasta = s_annotate.proteins,
          ko_ec_execute = fa_ko_ec_execute,
          ko_ec_img_nr_db = fa_ko_ec_img_nr_db,
          ko_ec_md5_mapping = fa_ko_ec_md5_mapping,
          ko_ec_taxon_to_phylo_mapping = fa_ko_ec_taxon_to_phylo_mapping,
          lastal_bin = fa_lastal_bin,
          selector_bin = fa_selector_bin,
          smart_execute = fa_smart_execute,
          smart_db = fa_smart_db,
          hmmsearch_bin = fa_hmmsearch_bin,
          frag_hits_filter_bin = fa_frag_hits_filter_bin,
          cog_execute = fa_cog_execute,
          cog_db = fa_cog_db,
          tigrfam_execute = fa_tigrfam_execute,
          tigrfam_db = fa_tigrfam_db,
          hit_selector_bin = fa_hit_selector_bin,
          superfam_execute = fa_superfam_excute,
          superfam_db = fa_superfam_db
      }
    }
  }
}

task setup {
  String dir
  Int    n_splits
  String fasta

  command {
    python -c 'for i in range(${n_splits}): print("${dir}"+str(i+1)+"/${fasta}")'
  }
  output {
    Array[File] splits = read_lines(stdout())
  }
}
