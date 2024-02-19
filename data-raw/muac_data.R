# Processing of datasets included in this project ------------------------------

muac_data <- read.csv(file = "https://github.com/OxfordIHTM/oxford-ihtm-forum/files/14256522/nut_data.csv") |>
  dplyr::select(state_name, district_name, age, sex, muac, oedema) |>
  tibble::tibble()

usethis::use_data(muac_data, overwrite = TRUE, compress = "xz")


load("data-raw/anthroAFG.rda")

afg_data <- anthroAFG |>
  subset(select = c(district, sex, age, muac, weight, height))


## Rajasthan fortification dataset ----
rajasthan_nut_data <- read.csv("data-raw/svyData.csv") |>
  subset(select = c(psu, hh, csex, cagem, oedema, cmuac))


## Myanmar data
load("data-raw/anthroDF.rda")
