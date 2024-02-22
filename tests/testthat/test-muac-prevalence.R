# Test MUAC prevalence ---------------------------------------------------------

muac_prevalence <- ipc_muac_check(
  df = muac_data, muac_units = "cm", oedema_recode = c(1, 2), .summary = FALSE
) |>
  ipc_calculate_prevalence(status = "sam")


testthat::expect_type(muac_prevalence, "double")


muac_prevalence <- muac_data |>
  dplyr::mutate(sex = ifelse(sex == 1, "m", "f")) |>
  ipc_muac_check(
    sex_recode = c("m", "f"), muac_units = "cm",
    oedema_recode = c(1, 2), .summary = FALSE
  ) |>
  ipc_calculate_prevalence(status = "mam")


testthat::expect_type(muac_prevalence, "double")
