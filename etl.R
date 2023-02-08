library(dplyr)

raw <- read.csv("input.csv")

standard_id_count <- length(
  select(
    raw,
    contains("standard_sample_id")
  )
)

for (i in 1:standard_id_count) {
  tmp <- select(
    raw,
    !matches("_[0-9]$") | matches(paste0("_", i, "$")) & !matches("__")
  )

  colnames(tmp) <- gsub(
    pattern = paste0("_", i, "$"),
    replacement = "",
    x = colnames(tmp)
  )

  if (exists("output")) {
    rbind(output, tmp)
  } else {
    output <- tmp
  }
}
