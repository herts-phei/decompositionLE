#' Title decomp_disease
#'
#' Function for performing life expectancy decomposition for disease groups
#'
#' @param df An outputted life table with
#' @param age_col Column providing ordered age bands with the final age group being an open-ended interval suffxied with '+', e.g. '90+'.. Of factor type.
#' @param group_1 Unique matching stem prefix in columns for group 1
#' @param group_1_m Column name for group 1 all-cause mortality rate between ages x and x + n
#' @param group_2 Unique matching stem prefix in columns for group 2
#' @param group_2_m Column name for group 2 all-cause mortality rate between ages x and x + n
#' @param nDx contribution of all-cause mortality differences in groups 1 and 2 in age groups x to x + n. Essentially the total effect column computed from `decomp_LE()`
#' @returns A data frame with life expectancy disease breakdown decomposition values
#' @export
#'
#' @examples
#' decomp_disease(india_china_males_1995, group_1 = "India", group_2 = "China")
#' @importFrom stringr str_detect
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate case_when lead

decomp_disease <- function(df, group_1, group_2, nDx) {
  india_china_males_1995 |>
    pivot_longer(
      cols = c(starts_with("India"), starts_with("China")) & !c("India_nmx", "China_nmx"),
      names_to = c(".value", "disease"),
      names_pattern = paste0("^(", "India", "|", "China", ")(.*)$")
    ) |>
    mutate(delta = ((.data[["China"]] - .data[["India"]]) / (.data[["China_nmx"]] - .data[["India_nmx"]])) * .data[["nDx"]]) %>%
    pivot_wider(
      names_from = "disease", values_from = c(.data[["China"]], .data[["India"]], `delta`),
      names_glue = "{.value}{disease}"
    ) %>%
    identity()
}
