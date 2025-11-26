#' Title plot.age
#'
#' Plot age decomposition breakdown
#'
#' @description
#' S3 method for \code{plot()} that visualizes age-related decomposition breakdowns from a data frame.
#' It pivots columns from `decomp_age()` output into a long format and creates a formatted bar plot.
#'
#' @param x A data frame containing `decomp_age()` output.
#' @param method Method used for age decomposition. Same as method argument in `decomp_age()`
#' @param line Logical for additional line geom showing total effect if segment plot is selected. TRUE by default.
#' @param plot_type Plot either total contribution in years or segmented effect contributrion. "total", "segment_dodge", or "segment_stack".
#'
#' @return A \code{ggplot} object showing disease breakdown values
#' @export
#' @method plot disease
#'
#' @examples
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr select rename mutate
#' @importFrom ggplot2 ggplot aes geom_col geom_line labs scale_fill_brewer scale_color_manual
#' @importFrom rlang enquo


plot.age <- function(x, method, plot_type, line = TRUE) {
  methods <- c("arriaga3", "chandrasekaran1", "chandrasekaran2")

  if (!method %in% methods) stop("Invalid method")

  plot_types <- c("")

  if (!plot_type %in% plot_types) stop("Invalid method")

  effect_lookup <- list(
    arriaga3 = c("direct_effect", "indirect_effect", "exclusive_effect", "interaction_effect"),
    chandrasekaran1 = c("main_effect", "operative_effect", "effect_interaction_deferred", "effect_interaction_forwarded")
  )


  df_long <- x |>
    pivot_longer(cols = effect_lookup[[method]], names_to = "effect", values_to = "contribution") |>
    mutate(across(effect, \(x) str_to_title(gsub("_", " ", x))))

  if (plot_type == "segment_dodge") {
    plot <- df_long |>
      ggplot(aes(Age, contribution, fill = effect)) +
      geom_col(position = "dodge") +
      labs(x = "Starting age of age band", y = "Contribution of difference (years)", color = NULL, fill = NULL) +
      scale_color_manual(values = c("Total Effect" = "black")) +
      theme_minimal()
  }

  if (plot_type == "segment_stack") {
    plot <- df_long |>
      ggplot(aes(Age, contribution, fill = effect)) +
      geom_col(position = "stack") +
      labs(x = "Starting age of age band", y = "Contribution of difference (years)", color = NULL, fill = NULL) +
      theme_minimal()

    if (line) {
      df_long_line <- df_long |>
        select(Age, total_effect) |>
        unique() |>
        rename("contribution" = "total_effect") |>
        mutate(type = "Total Effect")

      plot <- plot +
        geom_line(data = df_long_line, aes(Age, value, group = 1, colour = type), inherit.aes = FALSE) +
        scale_color_manual(values = c("Total Effect" = "black"))
    }
  }

  if (plot_type == "total") {
    plot <- df_long |>
      ggplot(aes(Age, total_effect)) +
      geom_col() +
      labs(x = "Starting age of age band", y = "Contribution of difference (years)") +
      theme_minimal()
  }
}

plot.age(moo, method = "arriaga3", plot_type = "dodge")
