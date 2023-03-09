multiome <- read.csv("/home/chris/downloads/multiome-tech-data.csv")
scrna <- read.csv("/home/chris/downloads/scrna-tech-data.csv")
clinical <- read.csv("/home/chris/downloads/clinical-data.csv")
sample <- read.csv("/home/chris/downloads/sample-data.csv")

a <- full_join(sample, scrna, by = "standard_id")
a <- select(a, order(colnames(a)))

write.csv(a, "tmp.csv", row.names = F)
