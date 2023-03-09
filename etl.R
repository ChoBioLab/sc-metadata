library(tidyverse)

raw <- read.csv("input.csv")

lib_prep_raw <- select(raw, !c(lib_id_seq_1:length(raw)))

# establish length of standard ID loop
lib_id_count <- length(
  select(
    raw,
    contains("lib_id_cyto_gex")
  )
)

# build lib ID table
for (i in 1:lib_id_count) {
  tmp <- select(
    lib_prep_raw,
    !matches("[a-z]_[0-9]$") |
      matches(paste0("[a-z]_", i, "$"))
  ) %>%
    filter(redcap_event_name == "forms_arm_1")

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
      lib_type = "ctyo-gex"
    )

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
    )

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
    )

  # cleanup column name strings specific to lib type
  colnames(cyto) <- gsub(
    pattern = "cyto_gex_|_cyto_gex",
    replacement = "",
    x = colnames(cyto)
  )

  colnames(nuc) <- gsub(
    pattern = "nuc_gex_|_nuc_gex",
    replacement = "",
    x = colnames(nuc)
  )

  colnames(atac) <- gsub(
    pattern = "atac_",
    replacement = "",
    x = colnames(atac)
  )

  colnames(atac) <- gsub(
    pattern = "id_atac",
    replacement = "id",
    x = colnames(atac)
  )

  # append rows to final table
  if (exists("final_table")) {
      print(colnames(atac))
      print(length(atac))
      print(length(nuc))
      print(length(cyto))
      print(colnames(cyto))
    final_table <- rbind(
      final_table,
      cyto,
      nuc,
      atac
    )
  } else {
      print(colnames(atac))
      print(length(atac))
      print(length(nuc))
      print(length(cyto))
      print(colnames(cyto))
    final_table <- rbind(
      cyto,
      nuc,
      atac
    )
  }
}


is.na(final_table) <- final_table == ""
final_table <- final_table %>%
  relocate(
    c(
      record_id,
      grid,
      standard_sample_id,
      lib_id,
      lib_type,
      patient_id,
      project_owner_id,
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
      no_of_samples_3_prime,
      x_chem_version_2_ma,
      no_of_samples_multiome,
      x_chem_version_sp,
      sample_information_complete,
      cdna_date,
      pcr_cycles,
      index_used,
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
      no_samples_di
    )
  ) %>%
  select(
    !c(
      redcap_event_name
    )
  ) %>%
  filter(
    !(lib_id == "NA")
  )

write.csv(final_table, "output.csv", row.names = F)
