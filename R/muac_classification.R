#'
#' Classification functions that support the main functions for working with
#' MUAC datasets
#'
#' @param p Numeric value for p-value of a statistical test used in the
#'   various checks applied.
#' @param std_dev Numeric value for standard deviation (SD) of a measurement
#'   usually MUAC.
#' @param age_ratio_class A character value or vector for classification based
#'   on the result of the age ratio test.
#' @param sex_ratio_class A character value or vector for classification based
#'   on the sex ratio test.
#' @param std_dev_class A character value for vector for classification based
#'   on standard deviation.
#' @param dps_class A character value for vector for classification based on
#'   the digit preference score (DPS)
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
#'   element for the value signifying presence of oedema and second element for
#'   the value signifying no oedema in the dataset. For example, if "y" is the
#'   value for presence of oedema and "n" is the value for no oedema, then
#'   specify `c("y", "n)`. If set to NULL (default), then the values c(1, 0)
#'   are used.
#'
#' @return A single value or a vector of values providing a classification
#'
#' @examples
#' age_ratio_p <- nipnTK::ageRatioTest(as.integer(!is.na(muac_data$age)))$p
#' classify_age_ratio(age_ratio_p)
#'
#' @rdname ipc_muac_class
#' @export
#'
#'
classify_age_ratio <- function(p) {
  cut(
    x = p,
    breaks = c(-Inf, 0.001, 0.05, 0.01, Inf),
    labels = c("Problematic", "Poor", "Acceptable", "Excellent"),
    include.lowest = FALSE, right = TRUE
  ) |>
    as.character()
}

#'
#' @rdname ipc_muac_class
#' @export
#'

classify_sex_ratio <- function(p) {
  cut(
    x = p,
    breaks = c(-Inf, 0.001, 0.05, 0.01, Inf),
    labels = c("Problematic", "Poor", "Acceptable", "Excellent"),
    include.lowest = FALSE, right = TRUE
  ) |>
    as.character()
}


#'
#' @rdname ipc_muac_class
#' @export
#'

classify_sd <- function(std_dev) {
  cut(
    x = std_dev,
    breaks = c(-Inf, 13, 14, 15, Inf),
    labels = c("Excellent", "Acceptable", "Poor", "Problematic"),
    include.lowest = TRUE, right = FALSE
  ) |>
    as.character()
}


#'
#' @rdname ipc_muac_class
#' @export
#'

classify_quality <- function(age_ratio_class,
                             sex_ratio_class,
                             std_dev_class,
                             dps_class) {
  age_ratio_score <- ifelse(age_ratio_class == "Problematic", 1, 0)
  sex_ratio_score <- ifelse(sex_ratio_class == "Problematic", 2, 0)
  std_dev_score <- ifelse(std_dev_class == "Problematic", 4, 0)
  dps_score <- ifelse(dps_class == "Problematic", 8, 0)

  quality_score <- age_ratio_score + sex_ratio_score + std_dev_score + dps_score
  names(quality_score) <- NULL

  quality_class <- dplyr::case_when(
    quality_score == 0 ~ "OK",
    quality_score <= 3 ~ "Partially OK",
    quality_score > 3 ~ "Not OK"
  )
  names(quality_class) <- NULL

  list(q_score = quality_score, q_class = quality_class)
}


#'
#' @rdname ipc_muac_class
#' @export
#'
classify_acute_malnutrition <- function(muac,
                                        muac_units = c("mm", "cm"),
                                        oedema,
                                        oedema_recode = NULL) {
  ## Determine which MUAC units to use ----
  muac_units <- match.arg(muac_units)

  ## Process MUAC based on units ----
  if (muac_units == "cm") muac <- muac * 10

  ## Process oedema data ----
  if (!is.null(oedema_recode))
    oedema <- ifelse(oedema == oedema_recode[[1]], 1, 0)

  dplyr::case_when(
    muac < 115 | oedema == 1 ~ "sam",
    muac >= 115 & muac < 125 & oedema == 0 ~ "mam",
    .default = "not sam or mam"
  )
}
