# Test muac missing data function ----------------------------------------------

## Create missing data ----

df <- muac_data
df[sample(seq_len(nrow(df)), size = 20), "muac"] <- NA_integer_

testthat::expect_s3_class(check_missing_data(df), "tbl")
