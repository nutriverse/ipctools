#'
#' Check missing anthropometry data
#'
#' @param df A data.frame with information on age, sex, oedema status, and
#'   MUAC of each child that has been processed using `process_muac_data()`
#'
#' @returns A tibble summarising number and percent missing data for age, sex,
#'   oedema status, and MUAC for the given `df`
#'
#' @examples
#' check_missing_data(muac_data)
#'
#' @rdname check_missing_muac
#' @export
#'
check_missing_data <- function(df) {
  df |>
    dplyr::summarise(
      n_missing_sex = sum(is.na(.data$sex)),
      p_missing_sex = .data$n_missing_sex / dplyr::n(),
      n_missing_age = sum(is.na(.data$age)),
      p_missing_age = .data$n_missing_age / dplyr::n(),
      n_missing_muac = sum(is.na(.data$muac)),
      p_missing_muac = .data$n_missing_muac / dplyr::n(),
      n_missing_oedema = sum(is.na(.data$oedema)),
      p_missing_oedema = .data$n_missing_oedema / dplyr::n(),
      .groups = "drop"
    )
}
