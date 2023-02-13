library(tidyverse)

raw <- read.csv("input.csv")

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

# build standard ID table
for (i in 1:standard_id_count) {
  tmp <- select(
    raw,
    !c(library_id_seq_1:reads_per_cell_20) &
      !matches("[a-z]_[0-9]$") |
      matches(paste0("[a-z]_", i, "$"))
  )

  colnames(tmp) <- gsub(
    pattern = paste0("[a-z]_", i, "$"),
    replacement = "",
    x = colnames(tmp)
  )

  if (exists("standard_id_sub")) {
    standard_id_sub <- rbind(standard_id_sub, tmp)
  } else {
    standard_id_sub <- tmp
  }
}

# isolate list of unique library IDs
lib_ids <- raw %>%
  select(contains("library_id")) %>%
  unlist() %>%
  unique()
is.na(lib_ids) <- lib_ids == ""
lib_ids <- na.omit(lib_ids)

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

colnames(tmp)
dim(tmp)
