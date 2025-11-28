#' Title plot_age
#'
#' Plot age decomposition breakdown
#'
#' @description
#' S3 method for \code{plot()} that visualizes age-related decomposition breakdowns from a data frame.
#' It pivots columns from `decomp_age()` output into a long format and creates a formatted bar plot.
#'
#' @param x A data frame containing unmodified `decomp_age()` output.
#' @param method Method used for age decomposition. Same as method argument in `decomp_age()`
#' @param line Logical for additional line geom showing total effect if 'segment_dodge' `plot_type` is selected. FALSE by default. Not available for 'chandrasekaran1' and 'chandrasekaran2' methods.
#' @param plot_type Plot either total contribution in years or segmented effect contribution. Options: "total", "segment_dodge".
#'
#' @return A \code{ggplot} object showing disease breakdown values
#' @export
#'
#' @examples
#' age_output <- decomp_age(us_females,
#'   method = "arriaga3", age_col = "Age", e1 = "e1x",
#'   e2 = "e2x", l1 = "l1x", l2 = "l2x"
#' )
#'
#' plot_age(age_output, method = "arriaga3", plot_type = "segment_dodge")
#' plot_age(age_output, method = "arriaga3", plot_type = "segment_dodge", line = TRUE)
#' plot_age(age_output, method = "arriaga3", plot_type = "total", line = TRUE)
#'
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr select rename mutate
#' @importFrom ggplot2 ggplot aes geom_col geom_line labs scale_fill_brewer scale_color_manual theme_minimal
#' @importFrom rlang enquo
#' @importFrom stringr str_to_title


plot_age <- function(x, method, plot_type, line = FALSE) {
  methods <- c("arriaga3", "chandrasekaran1", "chandrasekaran2")

  if (!method %in% methods) stop("Invalid method")

  plot_types <- c("total", "segment_dodge", "segment_stack")

  if (!plot_type %in% plot_types) stop("Invalid plot type")

  if (line & method == "chandrasekaran1") stop("Line not available for Chandrasekaran 1 method")

  effect_lookup <- list(
    arriaga3 = c("direct_effect", "indirect_effect", "exclusive_effect", "interaction_effect"),
    chandrasekaran1 = c("main_effect", "operative_effect", "effect_interaction_deferred", "effect_interaction_forwarded"),
    chandrasekaran2 = c("main_effect", "operative_effect", "effect_interaction_deferred", "effect_interaction_forwarded")
  )

  total_col <- list(
    arriaga3 = "total_effect",
    chandrasekaran1 = NA,
    chandrasekaran2 = "chandrasekaran2"
  )



  df_long <- x |>
    pivot_longer(cols = effect_lookup[[method]], names_to = "effect", values_to = "contribution") |>
    mutate(across(effect, \(x) str_to_title(gsub("_", " ", x))))

  if (line) {
    df_long_line <- df_long |>
      select(Age, total_col[[method]]) |>
      unique() |>
      rename("contribution" = total_col[[method]]) |>
      mutate(type = "Total Effect")
  }

  if (plot_type == "segment_dodge") {
    plot <- df_long |>
      ggplot(aes(Age, contribution, fill = effect)) +
      geom_col(position = "dodge") +
      labs(x = "Starting age of age band", y = "Contribution of difference (years)", color = NULL, fill = NULL) +
      theme_minimal()

    if (line) {
      plot <- plot +
        geom_line(data = df_long_line, aes(Age, contribution, group = 1, colour = type), inherit.aes = FALSE) +
        scale_color_manual(values = c("Total Effect" = "black"))
    }
  }


  # if (plot_type == "segment_stack") {
  #   plot <- df_long |>
  #     ggplot(aes(Age, contribution, fill = effect)) +
  #     geom_col(position = "stack") +
  #     labs(x = "Starting age of age band", y = "Contribution of difference (years)", color = NULL, fill = NULL) +
  #     theme_minimal()
  #
  # if (line) {
  #   df_long_line <- df_long |>
  #     select(Age, total_effect) |>
  #     unique() |>
  #     rename("contribution" = "total_effect") |>
  #     mutate(type = "Total Effect")
  #
  #   plot <- plot +
  #     geom_line(data = df_long_line, aes(Age, value, group = 1, colour = type), inherit.aes = FALSE) +
  #     scale_color_manual(values = c("Total Effect" = "black"))
  # }
  # }

  if (plot_type == "total") {
    plot <- df_long |>
      select(Age, all_of(total_col[[method]])) |>
      unique() |>
      ggplot(aes(Age, .data[[total_col[[method]]]])) +
      geom_col() +
      labs(x = "Starting age of age band", y = "Contribution of difference (years)") +
      theme_minimal()
  }

  return(plot)
}
