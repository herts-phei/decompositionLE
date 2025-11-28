#' Title plot_disease
#'
#' Plot disease decomposition breakdown
#'
#' @description
#' Visualize disease-related deltas from a data frame.
#' It pivots columns starting with \code{"delta"} and ending with user-specified suffixes
#' (e.g., \code{c("CD", "NCD", "Injuries")}) into a long format and creates a formatted stacked bar plot.
#'
#' @param x A data frame containing `decomp_disease()` output.
#' @param suffixes A character vector of disease suffixes to match (e.g., \code{c("CD", "NCD", "Injuries")}). Essentially the same as `diseases` argument in `decomp_disease()`.
#' @param nDx Column name for contribution of all-cause mortality differences in groups 1 and 2 in age groups x to x + n.
#' @param line Logical for additional line geom showing total effect. TRUE by default.
#'
#' @return A \code{ggplot} object showing disease breakdown values
#' @export
#'
#' @examples
#'
#' disease_data <- decomp_disease(india_china_males_1990,
#'   breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
#'   group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
#'   group_2_m = "China_nmx", nDx = "nDx"
#' )
#'
#' plot_disease(disease_data, c("delta_CD", "delta_NCD", "delta_Injuries"), "nDx", line = FALSE)
#' plot_disease(disease_data, c("delta_CD", "delta_NCD", "delta_Injuries"), "nDx", line = TRUE)
#'
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr select rename mutate
#' @importFrom ggplot2 ggplot aes geom_col geom_line labs scale_fill_brewer scale_color_manual theme_minimal
#' @importFrom rlang enquo

plot_disease <- function(x, suffixes, nDx, line = TRUE) {
  stopifnot(is.data.frame(x), is.character(suffixes))

  df_long <- x %>%
    tidyr::pivot_longer(
      cols = all_of(starts_with("delta")) & all_of(ends_with(suffixes)),
      names_to = "disease",
      values_to = "delta_value"
    )

  df_long_line <- df_long |>
    select(Age, {{ nDx }}) |>
    rename("value" = {{ nDx }}) |>
    unique() |>
    mutate(type = "Total Effect")


  return_plot <- df_long |>
    ggplot(aes(Age, delta_value, fill = disease)) +
    geom_col() +
    labs(x = "Starting age of age band", y = "Contribution of difference (years)", colour = NULL, fill = "Component") +
    scale_fill_brewer(palette = "Paired") +
    theme_minimal()


  if (line) {
    return_plot <- return_plot +
      geom_line(data = df_long_line, aes(Age, value, group = 1, colour = type), inherit.aes = FALSE) +
      scale_color_manual(values = c("Total Effect" = "black"))
  }

  return(return_plot)
}
