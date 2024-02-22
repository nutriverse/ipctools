# Tests for MUAC check functions -----------------------------------------------

## Test check function - list output ----
muac_check <- ipc_muac_check(
  df = muac_data, muac_units = "cm", oedema_recode = c(1, 2)
)

testthat::expect_type(muac_check, "list")
testthat::expect_vector(muac_check)
testthat::expect_named(
  muac_check,
  c("Age Ratio", "Sex Ratio", "Digit Preference",
    "Standard Deviation", "Data Quality")
)


## Test check function - non-list output ----
muac_check <- ipc_muac_check(
  df = muac_data, muac_units = "cm", oedema_recode = c(1, 2), .list = FALSE
)

testthat::expect_type(muac_check, "list")
testthat::expect_s3_class(muac_check, "tbl_df")
testthat::expect_vector(muac_check)
testthat::expect_equal(ncol(muac_check), 12)
testthat::expect_equal(nrow(muac_check), 1)


## Test check function - non-summary output ----
muac_check <- ipc_muac_check(
  df = muac_data, muac_units = "cm", oedema_recode = c(1, 2), .summary = FALSE
)

testthat::expect_type(muac_check, "list")
testthat::expect_s3_class(muac_check, "tbl_df")
testthat::expect_vector(muac_check)
testthat::expect_true(
  all(c("age_ratio", "age_ratio_p", "age_ratio_class", "sex_ratio", "sex_ratio_p",
    "sex_ratio_class", "digit_preference", "digit_preference_class", "std_dev",
    "std_dev_class", "quality_score", "quality_class") %in% names(muac_check))
)
testthat::expect_equal(nrow(muac_check), nrow(muac_data))


## Test check function - recode sex

muac_check <- muac_data |>
  dplyr::mutate(sex = ifelse(sex == 1, "m", "f")) |>
  ipc_muac_check(
    sex_recode = c("m", "f"), muac_units = "cm", oedema_recode = c(1, 2)
  )

testthat::expect_type(muac_check, "list")
testthat::expect_vector(muac_check)
testthat::expect_named(
  muac_check,
  c("Age Ratio", "Sex Ratio", "Digit Preference",
    "Standard Deviation", "Data Quality")
)
