# Processing of datasets included in this project ------------------------------

muac_data <- read.csv(file = "https://github.com/OxfordIHTM/oxford-ihtm-forum/files/14256522/nut_data.csv") |>
  dplyr::select(state_name, district_name, age, sex, muac, oedema) |>
  tibble::tibble()

usethis::use_data(muac_data, overwrite = TRUE, compress = "xz")
