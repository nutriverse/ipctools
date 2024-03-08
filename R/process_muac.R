#'
#' Process MUAC data
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
#'
#' @returns An appropriately structured data.frame that can be passed on to
#'   other functions
#'
#' @examples
#' process_muac_data(muac_data)
#'
#' @rdname process_muac
#' @export
#'
process_muac_data <- function(df,
                              age = "age",
                              sex = "sex",
                              sex_recode = NULL,
                              muac = "muac",
                              muac_units = c("mm", "cm"),
                              oedema = "oedema",
                              oedema_recode = NULL) {
  ## Determine MUAC units ----
  muac_units <- match.arg(muac_units)

  ## Retrieve required variables and rename to standard names ----
  df <- df |>
    dplyr::mutate(
      oedema = ifelse(is.null(!!oedema), NA_integer_, oedema)
    ) |>
    dplyr::rename(
      age = !!age,
      sex = !!sex,
      muac = !!muac
    )

  ## Recode sex to 1 = male and 2 = female ----
  if (!is.null(sex_recode)) {
    df <- df |>
      dplyr::mutate(sex = ifelse(sex == sex_recode[1], 1, 2))
  }

  ## Recode oedema to 0 = not present and 1 = present ----
  if (!is.null(oedema_recode)) {
    df <- df |>
      dplyr::mutate(oedema = ifelse(oedema == oedema_recode[1], 1, 0))
  }

  ## Convert muac to appropriate units - mm ----
  if (muac_units == "cm") {
    df <- df |> dplyr::mutate(muac = muac * 10)
  }

  ## Return processed muac data ----
  df
}
