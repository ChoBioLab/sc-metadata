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
