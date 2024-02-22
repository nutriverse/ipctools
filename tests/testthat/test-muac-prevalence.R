# Test MUAC prevalence ---------------------------------------------------------

muac_prevalence <- ipc_muac_check(
  df = muac_data, muac_units = "cm", oedema_recode = c(1, 2), .summary = FALSE
) |>
  ipc_calculate_prevalence(status = "sam")


testthat::expect_type(muac_prevalence, "double")
