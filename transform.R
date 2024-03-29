library(tidyverse)

raw <- read.csv("input.csv")

# Replace any NA values with empty strings
raw[is.na(raw)] <- ""
raw <- as_tibble(raw)

# Select columns from raw tibble that do not include lib_id_seq_1:length(raw)
arm1_raw <- select(
  raw,
  !c(lib_id_seq_1:length(raw))
)

arm2_raw <- select(
  raw,
  record_id,
  redcap_event_name,
  sequencing_center,
  c(lib_id_seq_1:length(raw))
)

# Determine number of lib_id_cyto_gex columns to process
arm1_rep_count <- length(
  select(
    raw,
    contains("lib_id_cyto_gex")
  )
)

arm2_rep_count <- length(
  select(
    raw,
    contains("lib_id_seq_")
  )
)

# Loop through each lib_id column and extract relevant data
for (i in 1:arm1_rep_count) {
  # Select data that is specific to the current lib_id column being processed
  tmp <- select(
    arm1_raw,
    !matches("[a-z]_[0-9]$") |
      matches(paste0("[a-z]_", i, "$"))
  ) %>%
    # Filter by redcap_event_name
    filter(redcap_event_name == "Forms (Arm 1: Sample Info and Library Prep)")

  # Rename columns to remove lib_id_cyto_gex suffix
  colnames(tmp) <- gsub(
    pattern = paste0("_", i, "$"),
    replacement = "",
    x = colnames(tmp)
  )

  # selct for lib type specific entries
  cyto <- select(
    tmp,
    !contains(
      c(
        "atac_",
        "lib_id_atac",
        "nuc_gex"
      )
    )
  ) %>%
    mutate(
      lib_type = "cyto-gex"
    ) %>%
    rename_with(., ~ gsub(
      pattern = "cyto_gex_|_cyto_gex",
      replacement = "",
      .x
    ))

  nuc <- select(
    tmp,
    !contains(
      c(
        "atac_",
        "lib_id_atac",
        "cyto_gex"
      )
    )
  ) %>%
    mutate(
      lib_type = "nuc-gex"
    ) %>%
    rename_with(., ~ gsub(
      pattern = "nuc_gex_|_nuc_gex",
      replacement = "",
      .x
    ))

  atac <- select(
    tmp,
    !contains(
      c(
        "cyto_gex",
        "nuc_gex"
      )
    )
  ) %>%
    mutate(
      lib_type = "atac"
    ) %>%
    rename_with(., ~ gsub(
      pattern = "atac_",
      replacement = "",
      .x
    )) %>%
    rename_with(., ~ gsub(
      pattern = "id_atac",
      replacement = "id",
      .x
    ))

  # append rows to final table
  if (exists("final_table")) {
    final_table <- bind_rows(
      final_table,
      cyto,
      nuc,
      atac
    )
  } else {
    final_table <- bind_rows(
      cyto,
      nuc,
      atac
    )
  }
}

for (i in 1:arm2_rep_count) {
  # Select data that is specific to the current lib_id column being processed
  tmp <- select(
    arm2_raw,
    record_id,
    redcap_event_name,
    sequencing_center,
    matches(paste0("[a-z]_", i, "$")),
    sequencing_complete
  ) %>%
    # Filter by redcap_event_name
    filter(redcap_event_name == "Forms (Arm 2: Sequencing)")

  # Rename columns to remove lib_id_cyto_gex suffix
  colnames(tmp) <- gsub(
    pattern = paste0("_", i, "$"),
    replacement = "",
    x = colnames(tmp)
  )

  if (exists("seq_table")) {
    seq_table <- bind_rows(
      seq_table,
      tmp
    )
  } else {
    seq_table <- bind_rows(
      tmp
    )
  }
}

# Replace empty strings with NA in final_table
is.na(final_table) <- final_table == ""

final_table <- final_table %>%
  select(!c(redcap_event_name)) %>%
  filter(!(lib_id == "NA")) %>%
  rename(c(
    index = index_used,
    subject_id = record_id,
    standard_id = standard_sample_id
  ))

# Replace empty strings with NA in seq_table
is.na(seq_table) <- seq_table == ""

seq_table <- seq_table %>%
  select(!c(redcap_event_name)) %>%
  filter(!(lib_id_seq == "NA")) %>%
  rename(c(
    lib_id = lib_id_seq,
    data_release = record_id
  ))

final_table <- full_join(
  seq_table,
  final_table,
  by = "lib_id",
  suffix = c("", ".y")
) %>%
  select(-ends_with(".y"))

final_table <- final_table %>%
  relocate(
    c(
      standard_id,
      lib_id,
      lib_type,
      grid,
      subject_id,
      patient_id,
      project_owner_id,
      data_release,
      organism,
      project,
      other_project,
      disease,
      other_disease,
      disease_status,
      sample_origin,
      procedure,
      animal_line,
      inflam_status,
      other_inflam_status,
      tissue_origin,
      other_tissue_origin,
      sc_process_date,
      sc_isolation_prot,
      lithium_chloride_cleaning,
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
      type_of_experiment___3prime,
      type_of_experiment___atac,
      type_of_experiment___spatialffpe,
      type_of_experiment___spatialoct,
      x_chem_version_sc,
      no_samples_di,
      no_of_samples_3_prime,
      x_chem_version_2_ma,
      no_of_samples_multiome,
      x_chem_version_sp,
      sample_information_complete,
      cdna_date,
      pcr_cycles,
      cdna_conc,
      cdna_conc_dilution,
      total_cdna_yield,
      input_cdna,
      index,
      lib_conc,
      lib_dilution,
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
      number_of_reads,
      reads_per_cell,
      sequencing_complete
    )
  )

write.csv(final_table, "scmeta-table/samples-out.csv", row.names = F)
