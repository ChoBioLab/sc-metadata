library(dplyr)

length(select(a, contains("standard_sample_id")))

a <- read.csv('input.csv')

b <- a %>%
    select(!matches("_[0-9]$") | matches("_2$"))

