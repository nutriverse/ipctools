#'
#' Perform MUAC check based on IPC and CDC recommendations
#'
#' @param df A data.frame with information on age, sex, oedema status, and
#'   MUAC of each child
#' @param age A character value for name of variable in `df` for age of
#'   child. The age of child should be in months.
#' @param sex A character value for name of variable in `df` for sex of child.
#'   The expected values for `sex` is 1 = males; 2 = females. If data values
#'   are different, use `sex_recode` to map out the values to what is
#'   required.
#' @param sex_recode A vector of values with length of 2 with the first
#'   element for the value signifying males and second element for the value
#'   signifying females in the dataset. For example, if "m" is the value for
#'   males and "f" is the value for females, then specify `c("m", "f)`. If
#'   set to NULL (default), then the values c(1, 2) are used.
#' @param muac A character value for name of variable in `df` for MUAC
#'   measurement of child. The expected values for MUAC are in millimetres.
#'   If units are different, use `muac_units` to specify which units are used.
#' @param muac_units A character value for units used for MUAC measurement.
#'   Currently accepts either "mm" for millimetres (default) or "cm" for
#'   centimetres.
#' @param oedema A character value for name of variable in `df` for oedema
#'   status of child. The expected values for `oedema` is 1 = for presence of
#'   oedema and 2 for no oedema. If data values are different, use
#'   `oedema_recode` to map out the values to what is required. If dataset
#'   does not have oedema values, set this to NULL.
#' @param oedema_recode A vector of values with length of 2 with the first
#'   element for the value signifying presence of oedema and second element for
#'   the value signifying no oedema in the dataset. For example, if "y" is the
#'   value for presence of oedema and "n" is the value for no oedema, then
#'   specify `c("y", "n)`. If set to NULL (default), then the values c(1, 0)
#'   are used.
#' @param .summary Logical. Should output be a summary of all the checks
#'   performed on the MUAC dataset? If TRUE (default), output will be a single
#'   row data.frame with each column for each metric used to check MUAC
#'   dataset. If FALSE, a data.frame with same number of rows as `df` and
#'   columns for each metric used to check MUAC dataset is added to `df`.
#'   Setting `.summary` to FALSE is usually only used for when the output
#'   structure is required for further analysis (i.e., calculation of
#'   prevalence).
#' @param .list Logical. Relevant only if `.summary` is TRUE. Should summary be
#'   given in list format? If TRUE (default), then the output is in list format
#'   otherwise a data.frame is provided.
#'
#' @return A data.frame with a single row with each column for each metric used
#'   to check MUAC dataset if `.summary` is TRUE. If `.summary` is FALSE, a
#'   data.frame with same number of rows as `df` and columns for each metric
#'   used to check MUAC dataset is added to `df`.
#'
#' @examples
#' ipc_muac_check(df = muac_data, oedema_recode = c(1, 2), muac_units = "cm")
#'
#' @rdname ipc_muac_check
#' @export
#'
#'
ipc_muac_check <- function(df,
                           age = "age",
                           sex = "sex",
                           sex_recode = NULL,
                           muac = "muac",
                           muac_units = c("mm", "cm"),
                           oedema = "oedema",
                           oedema_recode = NULL,
                           .summary = TRUE,
                           .list = TRUE) {
  ## Process muac data ----
  process_muac_data(
    df,
    age = age,
    sex = sex,
    sex_recode = sex_recode,
    muac = muac,
    muac_units = muac_units,
    oedema = oedema,
    oedema_recode = oedema_recode
  ) |>
    ## Perform MUAC check ----
    summarise_muac_check(.summary = .summary, .list = .list)
}

#'
#' @rdname ipc_muac_check
#' @export
#'

summarise_muac_check <- function(df, .summary = TRUE, .list = TRUE) {
  if (.summary) {
    muac_check <- df |>
      dplyr::summarise(
        age_ratio = nipnTK::ageRatioTest(as.integer(!is.na(.data$age)))$observedR,
        age_ratio_p = nipnTK::ageRatioTest(as.integer(!is.na(.data$age)))$p,
        sex_ratio = nipnTK::sexRatioTest(.data$sex, codes = c(1, 2))$pM,
        sex_ratio_p = nipnTK::sexRatioTest(.data$sex, codes = c(1, 2))$p,
        digit_preference = nipnTK::digitPreference(.data$muac, digits = 0)$dps,
        digit_preference_class = nipnTK::digitPreference(
          .data$muac, digits = 0
        )$dpsClass |>
          (\(x) { names(x) <- NULL; x })(),
        std_dev = stats::sd(.data$muac, na.rm = TRUE),
        age_ratio_class = classify_age_ratio(.data$age_ratio_p),
        sex_ratio_class = classify_sex_ratio(.data$sex_ratio_p),
        std_dev_class = classify_sd(.data$std_dev),
        quality_score = classify_quality(
          .data$age_ratio_class, .data$sex_ratio_class,
          .data$std_dev_class, .data$digit_preference_class
        )$q_score
      ) |>
      dplyr::mutate(
        quality_class = classify_quality(
          .data$age_ratio_class, .data$sex_ratio_class,
          .data$std_dev_class, .data$digit_preference_class
        )$q_class
      ) |>
      dplyr::relocate(.data$age_ratio_class, .after = "age_ratio_p") |>
      dplyr::relocate(.data$sex_ratio_class, .after = "sex_ratio_p") |>
      dplyr::relocate(.data$std_dev_class, .after = "std_dev")

    if (.list) {
      muac_check <- list(
        `Age Ratio` = list(
          ratio = muac_check$age_ratio,
          p = muac_check$age_ratio_p,
          class = muac_check$age_ratio_class
        ),
        `Sex Ratio` = list(
          ratio = muac_check$sex_ratio,
          p = muac_check$sex_ratio_p,
          class = muac_check$sex_ratio_class
        ),
        `Digit Preference` = list(
          score = muac_check$digit_preference,
          class = muac_check$digit_preference_class
        ),
        `Standard Deviation` = list(
          std_dev = muac_check$std_dev,
          class = muac_check$std_dev_class
        ),
        `Data Quality` = list(
          score = muac_check$quality_score,
          class = muac_check$quality_class
        )
      )
    } else {
      muac_check
    }
  } else {
    muac_check <- df |>
      dplyr::mutate(
        age_ratio = nipnTK::ageRatioTest(as.integer(!is.na(.data$age)))$observedR,
        age_ratio_p = nipnTK::ageRatioTest(as.integer(!is.na(.data$age)))$p,
        sex_ratio = nipnTK::sexRatioTest(.data$sex, codes = c(1, 2))$pM,
        sex_ratio_p = nipnTK::sexRatioTest(.data$sex, codes = c(1, 2))$p,
        digit_preference = nipnTK::digitPreference(.data$muac, digits = 0)$dps,
        digit_preference_class = nipnTK::digitPreference(
          .data$muac, digits = 0
        )$dpsClass,
        std_dev = stats::sd(.data$muac, na.rm = TRUE),
        age_ratio_class = classify_age_ratio(.data$age_ratio_p),
        sex_ratio_class = classify_sex_ratio(.data$sex_ratio_p),
        std_dev_class = classify_sd(.data$std_dev),
        quality_score = classify_quality(
          .data$age_ratio_class, .data$sex_ratio_class,
          .data$std_dev_class, .data$digit_preference_class
        )$q_score,
        quality_class = classify_quality(
          .data$age_ratio_class, .data$sex_ratio_class,
          .data$std_dev_class, .data$digit_preference_class
        )$q_class
      ) |>
      dplyr::relocate(.data$age_ratio_class, .after = "age_ratio_p") |>
      dplyr::relocate(.data$sex_ratio_class, .after = "sex_ratio_p") |>
      dplyr::relocate(.data$std_dev_class, .after = "std_dev")
  }

  ## Return muac_check ----
  muac_check
}

