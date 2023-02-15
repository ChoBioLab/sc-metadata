library(tidyverse)

raw <- read.csv("input.csv")

lib_prep_raw <- select(raw, !c(library_id_seq_1:length(raw)))
sequencing_raw <- select(raw, c(library_id_seq_1:length(raw)))

# establish length of library ID loop
lib_id_count <- length(
  select(
    raw,
    contains("library_id_seq")
  )
)

# establish length of standard ID loop
standard_id_count <- length(
  select(
    raw,
    contains("standard_sample_id")
  )
)

# isolate list of unique library IDs
lib_ids <- raw %>%
  select(contains("library_id")) %>%
  unlist() %>%
  unique()
is.na(lib_ids) <- lib_ids == ""
lib_ids <- na.omit(lib_ids)

# build standard ID table
for (i in 1:standard_id_count) {
  tmp <- select(
    lib_prep_raw,
    !matches("[a-z]_[0-9]$") |
      matches(paste0("[a-z]_", 2, "$"))
  ) %>%
    filter(redcap_event_name == "forms_arm_1")

  colnames(tmp) <- gsub(
    pattern = paste0("_", i, "$"),
    replacement = "",
    x = colnames(tmp)
  )

  # TODO make consistent set of vars for libraries
  # TODO add function to sub out modality specific strings to make rows compatible (e.g. cyto, nuc..)
  cyto <- select(
    tmp,
    !contains(c("atac", "nuc_gex"))
  )

  nuc <- select(
    tmp,
    !contains(c("atac", "cyto_gex"))
  )

  atac <- select(
    tmp,
    !contains(c("cyto_gex", "nuc_gex"))
  )

  if (exists("standard_id_subset")) {
    standard_id_subset <- rbind(
      standard_id_subset,
      cyto,
      nuc,
      atac
    )
  } else {
    standard_id_subset <- rbind(
      cyto,
      nuc,
      atac
    )
  }
}


# build library ID table
for (i in lib_ids) {
  tmp <- raw %>%
    filter(
      if_any(
        everything(),
        ~ . == i
      )
    ) %>%
    mutate(
      key_lib_id = i,
      .before = record_id
    )

  if (exists("lib_id_raw")) {
    lib_id_raw <- rbind(lib_id_raw, tmp)
  } else {
    lib_id_raw <- tmp
  }

  # TODO clean up lib_id_raw table
}

is.na(standard_id_subset) <- standard_id_subset == ""

standard_id_subset <- standard_id_subset %>% select(
  c(
    record_id,
    standard_sample_id,
    library_id_lp,
    library_id_gex,
    library_id_atac,
    grid,
    patient_id,
    redcap_event_name,
    organism,
    project,
    other_project,
    disease,
    other_disease,
    disease_status,
    sample_origin,
    procedure,
    animal_line,
    sc_process_date,
    sc_isolation_prot,
    lithium_chloride_cleaning,
    type_of_experiment___a,
    type_of_experiment___b,
    type_of_experiment___c,
    type_of_experiment___c.1,
    x_chem_version_sc,
    no_of_samples_3_prime,
    x_chem_version_2_ma,
    no_of_samples_multiome,
    x_chem_version_sp,
    sample_information_complete,
    inflam_status,
    other_inflam_status,
    tissue_origin,
    other_tissue_origin,
    no_live_cells,
    cell_viability_percentage,
    dead_cell_removal,
    viablity_after_dead_cell,
    no_cells,
    targ_cell,
    notes_sample_prime,
    no_live_nuclei,
    nuc_viability_percentage,
    dead_nuclei_removal,
    viablity_after_dead_nuclei,
    no_nuclei,
    targ_nuclei,
    notes_sample_multi,
    cdna_conc,
    cdna_conc_dilution,
    total_cdna_yield,
    input_cdna,
    pcr_cycles,
    index_used,
    average_bp,
    final_lib_conc,
    final_library_dilution,
    notes,
    atac_pcr_cycles,
    atac_index_used,
    atac_avg_bp,
    atac_lib_conc,
    atac_lib_dilution,
    cdna_pcr_cycles,
    gex_index_used,
    gex_lib_conc,
    gex_lib_dilution,
    notes_lp_atac,
    cdna_date,
    index_kit,
    pre_amp_date,
    index_kit_scm,
    library_prep_complete,
    date_sent,
    dual_single_index,
    sequencing_center,
    other_sequencing_center,
    instrument,
    novaseq_6000,
    novaseq_2000,
    lanes_full_flow_cell,
    number_of_lanes,
    no_samples_di,
    sequencing_complete,
    est_no_cells,
    mean_reads_per_cell,
    median_genes_per_cell,
    valid_barcodes,
    sequencing_saturation,
    q30_bases_in_barcode,
    q30_bases_in_rna_read,
    q30_bases_in_umi,
    reads_mapped_to_genome,
    reads_mapped_confi_genome,
    reads_map_conf_interger,
    reads_map_confi_intronic,
    reads_map_confi_exonic,
    reads_map_confi_transcript,
    reads_map_antisense_gene,
    fraction_reads_in_cells,
    total_genes_detected,
    median_umi_counts_per_cell,
    sequencing_qc_complete
  )
)



colnames(tmp)
dim(tmp)
