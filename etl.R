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
  )

  atac <- select(
    tmp,
    !contains(
      c(
        "cyto_gex",
        "nuc_gex"
      )
    )
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
      grid,
      standard_sample_id,
      lib_id
    ),
    .after = record_id
  ) %>%
  select(
    !c(
      redcap_event_name
    )
  )

write.csv(final_table, "output.csv", row.names = F)

