# Tests for MUAC classification functions --------------------------------------

## Test age ratio classifier ----
age_ratio_result <- nipnTK::ageRatioTest(muac_data$age)
age_ratio_class <- classify_age_ratio(p = age_ratio_result$p)

testthat::expect_type(age_ratio_class, "character")
testthat::expect_vector(age_ratio_class)


## Test sex ratio classifier ----
sex_ratio_result <- nipnTK::sexRatioTest(muac_data$sex)
sex_ratio_class <- classify_sex_ratio(p = sex_ratio_result$p)

testthat::expect_type(sex_ratio_class, "character")
testthat::expect_vector(sex_ratio_class)


## Digit preference score classifier ----
dps_result <- nipnTK::digitPreference(muac_data$muac)
dps_class <- dps_result$dpsClass

testthat::expect_type(dps_class, "character")
testthat::expect_vector(dps_class)


## Standard deviation
sd_results <- sd(muac_data$muac)
sd_class <- classify_sd(sd_results)

testthat::expect_type(sd_class, "character")
testthat::expect_vector(sd_class)


## Data Quality
q_results <- classify_quality(age_ratio_class, sex_ratio_class, dps_class, sd_class)

testthat::expect_type(q_results, "list")
testthat::expect_vector(q_results)
testthat::expect_named(q_results, c("q_score", "q_class"))

