source("read_census_table.R")

fields <- list(
  "Total population",
  c("Male", "25 to 29 years"),
  c("Female", "25 to 29 years"),
  "asdasda"
);

test <- read_census_table("census_samples/AGE AND SEX", "ACS_15_1YR_S0101", fields)
write.csv(test, paste("output_samples/ACS_15_1YR_S0101.csv", sep=""), row.names=F)