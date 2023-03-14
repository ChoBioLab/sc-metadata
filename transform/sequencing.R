# create a vector for the first column
column1 <- c("A", "B", "C", "D", "E")

# create a vector for the second column
column2 <- c(1, 2, 3, 4, 5)

# create a vector for the third column
column3 <- c(TRUE, FALSE, TRUE, FALSE, TRUE)

# create a dataframe with the three columns
test_dataframe <- data.frame(column1, column2, column3)

# print the test dataframe
write.csv(test_dataframe, "scmeta-table/sequencing-out.csv")

