#'
#' Calculate wasting prevalence by MUAC
#'
#' @param df A data.frame for a MUAC dataset on which appropriate checks have
#'   been applied already produced via a call to `ipc_muac_check()` with the
#'   `.summary` argument set to FALSE.
#' @param age A numeric or integer value or vector of values for age of child.
#'   The age of child should be in months.
#' @param sex A value or a vector of values for sex of child. The expected
#'   values for `sex` is 1 = males; 2 = females. If data values are different,
#'   use `sex_recode` to map out the values to what is required.
#' @param sex_recode A vector of values with length of 2 with the first
#'   element for the value signifiying males and second element for the value
#'   signifying females in the dataset. For example, if "m" is the value for
#'   males and "f" is the value for females, then specify `c("m", "f)`. If
#'   set to NULL (default), then the values c(1, 2) are used.
#' @param muac A numeric value or vector of numeric values for MUAC measurement
#'   of child. The expected values for MUAC are in millimetres. If units are
#'   different, use `muac_units` to specify which units are used.
#' @param muac_units A character value for units used for MUAC measurement.
#'   Currently accepts either "mm" for millimetres (default) or "cm" for
#'   centimetres.
#' @param oedema A value or a vector of values for oedema status of child. The
#'   expected values for `oedema` is 1 = for presence of oedema and 2 for no
#'   oedema. If data values are different, use `oedema_recode` to map out the
#'   values to what is required.
#' @param oedema_recode A vector of values with length of 2 with the first
#'   element for the value signifiying presence of oedema and second element for
#'   the value signifying no oedema in the dataset. For example, if "y" is the
#'   value for presence of oedema and "n" is the value for no oedema, then
#'   specify `c("y", "n)`. If set to NULL (default), then the values c(1, 0)
#'   are used.
#' @param status Which wasting anthropometric indicator to report. A choice
#'   between c("sam", "mam"). Default to "sam"
#'
#' @return A single value, a vector of values, or a table providing a prevalence
#'
#' @examples
#' calculate_unweighted_prevalence(
#'   muac = muac_data$muac,
#'   oedema = muac_data$oedema,
#'   status = "sam"
#' )
#'
#' ipc_muac_check(
#'   muac_data, age = "age", sex = "sex",
#'   muac = "muac", muac_units = "cm",
#'   oedema = "oedema", oedema_recode = c(1, 2),
#'   .summary = FALSE
#' ) |>
#' ipc_calculate_prevalence()
#'
#'
#' @rdname ipc_prevalence
#' @export
#'
#'
calculate_unweighted_prevalence <- function(muac,
                                            muac_units = c("mm", "cm"),
                                            oedema,
                                            oedema_recode = NULL,
                                            status = c("sam", "mam")) {
  ## Determine which nutrition status to get prevalence of ----
  status <- match.arg(status)

  ## Determine MUAC units ----
  muac_units <- match.arg(muac_units)

  ## Classify nutrition status ----
  nut_status <- classify_acute_malnutrition(
    muac = muac, muac_units = muac_units,
    oedema = oedema, oedema_recode = oedema_recode
  )

  ## Recode ----
  if (status == "sam") nut_status <- ifelse(nut_status == "sam", 1, 0)
  if (status == "mam") nut_status <- ifelse(nut_status == "mam", 1, 0)

  ## Calculate prevalence ----
  prevalence <- mean(nut_status,  na.rm = TRUE)

  ## Return prevalence ----
  prevalence
}

#'
#' @rdname ipc_prevalence
#' @export
#'

## Function to calculate weigthted prevalence ----
calculate_weighted_prevalence <- function(age,
                                          sex,
                                          sex_recode = NULL,
                                          muac,
                                          muac_units = c("mm", "cm"),
                                          oedema,
                                          oedema_recode = NULL,
                                          status = c("sam", "mam")) {
  ## Determine which nutrition status to get prevalence of ----
  status <- match.arg(status)

  ## Classify nutrition status ----
  muac_units <- match.arg(muac_units)
  nut_status <- classify_acute_malnutrition(
    muac = muac, muac_units = muac_units,
    oedema = oedema, oedema_recode = oedema_recode
  )

  ## Recode nut_status ----
  if (status == "sam") nut_status <- ifelse(nut_status == "sam", 1, 0)
  if (status == "mam") nut_status <- ifelse(nut_status == "mam", 1, 0)

  ## Recode age group ----
  age_group <- ifelse(age < 24, 1, 2)

  ## Recode sex ----
  if (!is.null(sex_recode)) sex <- ifelse(sex == sex_recode[1], 1, 2)

  ## Calculate weighted prevalence ----
  prevalence <- data.frame(age_group, sex, nut_status) |>
    dplyr::group_by(sex, age_group) |>
    dplyr::summarise(
      prevalence = mean(nut_status, na.rm = TRUE), .groups = "drop_last"
    ) |>
    dplyr::summarise(
      prevalence = sum(prevalence, na.rm = TRUE), .groups = "drop"
    ) |>
    dplyr::mutate(prevalence = ifelse(sex == 2, prevalence * (2 / 3), prevalence)) |>
    dplyr::summarise(prevalence = sum(prevalence, na.rm = TRUE))

  ## Return weighted prevalence ----
  prevalence$prevalence
}

#'
#' @rdname ipc_prevalence
#' @export
#'

## Function to calculate prevalence (weighted or unweighted as appropriate) ----
ipc_calculate_prevalence <- function(df,
                                     status = c("sam", "mam")) {
  ## Get nut status to work on ----
  status <- match.arg(status)

  ## Calculate prevalence data.frame ----
  prevalence <- df |>
    dplyr::summarise(
      quality_class = unique(.data$quality_class),
      unweighted_prevalence = calculate_unweighted_prevalence(
        muac = .data$muac, oedema = .data$oedema, status = status
      ),
      weighted_prevalence = calculate_weighted_prevalence(
        age = .data$age, sex = .data$sex,
        muac = .data$muac, oedema = .data$oedema,
        status = status
      ),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      prevalence = dplyr::case_when(
        quality_class == "OK" ~ unweighted_prevalence,
        quality_class == "Partially OK" ~ weighted_prevalence,
        .default = NA
      )
    )

  ## Return prevalence vector ----
  prevalence$prevalence
}

