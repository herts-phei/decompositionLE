#' Title decomp_disease
#'
#' Function for performing life expectancy decomposition for disease groups
#'
#' @param df An outputted life table with
#' @param breakdown Whether disease breakdowns are raw mortality rates or a decimal proportion of total all-cause mortality rate. Accepts either 'proportion' or 'raw'.
#' @param group_1 Unique matching stem prefix in columns for group 1 related disease cause breakdowns
#' @param group_1_m Column name for group 1 all-cause mortality rate between ages x and x + n
#' @param group_2 Unique matching stem prefix in columns for group 2 related disease cause breakdowns
#' @param group_2_m Column name for group 2 all-cause mortality rate between ages x and x + n
#' @param nDx Column name for contribution of all-cause mortality differences in groups 1 and 2 in age groups x to x + n. Essentially the total effect column computed from `decomp_LE()`.
#' @returns A data frame with life expectancy disease breakdown decomposition values
#' @export
#'
#' @examples
#' decomp_disease(india_china_males_1995, group_1 = "India", group_1_m = "India_nmx", group_2 = "China", group_2_m = "China_nmx", nDx = "nDx")
#' @importFrom stringr str_detect
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate case_when lead

decomp_disease <- function(df, breakdown = "proportion", group_1, group_1_m, group_2, group_2_m, nDx) {
  if (!breakdown %in% c("proportion", "raw")) stop("Invalid breakdown argument selected")

  df_colnames <- colnames(df)


  df |>
    pivot_longer(
      cols = c(starts_with(group_1), starts_with(group_2)) & !c(group_1_m, group_2_m),
      names_to = c(".value", "disease"),
      names_pattern = paste0("^(", group_1, "|", group_2, ")(.*)$")
    ) |>
    mutate(delta = case_when(
      breakdown == "raw" ~ (.data[[nDx]] * (.data[[group_2]] - .data[[group_1]]) / (.data[[group_2_m]] - .data[[group_1_m]])),
      breakdown == "proportion" ~ (.data[[nDx]] * ((.data[[group_2]] * .data[[group_2_m]]) - (.data[[group_1]] * .data[[group_1_m]])) / (.data[[group_2_m]] - .data[[group_1_m]]))
    )) |>
    pivot_wider(
      names_from = "disease", values_from = c(.data[[group_2]], .data[[group_1]], `delta`),
      names_glue = "{.value}{disease}"
    ) |>
    select(df_colnames, everything()) |>
    identity()
}

# 5.6 * (((0.677 * 0.0084) - (0.882 * 0.0267)) / (0.0084 - 0.0267))
