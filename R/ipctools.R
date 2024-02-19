#'
#' Utilities to Support Integrated Food Security Phase Classification (IPC) Data
#' Analysis and Visualisation
#'
#' The Integrated Food Security Phase Classification (IPC) is a widely used tool
#' for classifying and analyzing the severity and magnitude of food insecurity
#' and malnutrition situations in various countries and regions around the
#' world. It provides a common understanding of the food security situation and
#' enables decision-makers to take appropriate actions to mitigate and respond
#' to food crises. This package provides functions and utilities that support
#' IPC-related data analysis and visualisation.
#'
#' @docType package
#' @keywords internal
#' @name ipctools
#' @importFrom dplyr mutate summarise rename relocate case_when group_by
#' @importFrom nipnTK ageRatioTest sexRatioTest digitPreference
#' @importFrom stats sd
#' @importFrom rlang .data
#'
"_PACKAGE"
