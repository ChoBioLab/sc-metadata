library(tidyverse)

multiome <- read.csv("/home/chris/downloads/multiome-tech-data.csv")
scrna <- read.csv("/home/chris/downloads/scrna-tech-data.csv")
clinical <- read.csv("/home/chris/downloads/clinical-data.csv")
sample <- read.csv("/home/chris/downloads/sample-data.csv")

a <- full_join(sample, scrna, by = "lib_id")
a <- select(a, order(colnames(a)))

write.csv(a, "tmp.csv", row.names = F)
tmp <- read.csv("/home/chris/projects/sc-metadata/tmp.csv")

b <- full_join(tmp, multiome, by = "standard_id")

write.csv(b, "tmp1.csv", row.names = F)
tmp1 <- read.csv("/home/chris/projects/sc-metadata/tmp1.csv")

c <- full_join(tmp1, clinical, by = "subject_id") %>%
  select(c(
    "project",
    "lib_id",
    "standard_id",
    "subject_id",
    "grid_id",
    "patient_id",
    "project_owner_id",
    "age",
    "sex",
    "race",
    "animal_line",
    "cells_isolated",
    "cells_loaded",
    "disease_status",
    "inflammation_status",
    "sample_tissue_origin",
    "species",
    "experiement",
    "date_sc_processing",
    "data_release",
    "lib_batch",
    "seq_platform",
    "index",
    "repeat_data_release",
    "repeat_seq_platform",
    "date_cdna_amp",
    "viability",
    "working_concentration",
    "nuclei_isolated",
    "nuclei_loaded",
    "X10x_chem",
    "ref_genome",
    "data_link"
  ))
write.csv(c, "tmp2.csv", row.names = F)
