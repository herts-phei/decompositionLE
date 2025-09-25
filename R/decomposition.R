#' Title decomposition
#'
#' description Function for performing life expectancy decomposition.
#'
#' @param df An outputted life table with
#' @param method Methods to use for life expectancy decomposition. Defaults to 'arriaga3'. Current methods available are: 'arriaga3', 'arriaga2'. Future available methods will include:
#' @param age_col Column providing ordered age bands with the final age group being an open-ended interval suffxied with '+', e.g. '90+'.. Of factor type.
#' @param e1 Column name for expectation of life at age group x, in the 1st group of comparison.
#' @param e2 Column name for expectation of life at age group x, in the second group of comparison.
#' @param l1 Column name for The number of persons alive at age group x, in the 1st group of comparison.
#' @param l2 Column name for The number of persons alive at age group x, in the 1st group of comparison.
#' @param append Whether to append the decomposition columns to the original data frame.
#'
#' @returns A data frame with life expectancy decomposition values
#' @export
#'
#' @examples
#' decomposition(us_females, age_col = "Age", e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x")
#'
decomposition <- function(df, method = "arriaga3", age_col, e1, e2, l1, l2, append = TRUE) {
  if (!is.factor(df[[age_col]])) stop("The age column is not of type factor")

  age_band_logical <- levels(df[[age_col]]) |>
    as.vector() |>
    str_detect("\\+")

  if (age_band_logical |> sum() == 0) stop("No open-ended age band found. The last level must be the sole open-ended age band suffixed with '+'")
  if (age_band_logical |> sum() > 1) stop("More than one open age band found. The last level must be the sole open age band suffixed with '+'")
  if (isFALSE(age_band_logical[length(age_band_logical)] && sum(age_band_logical) == 1)) stop("The last age band is not open-ended. Another age band is open-ended.")





  df %>% mutate(
    ## direct ####
    direct_effect = case_when(
      !str_detect(.data[[age_col]], "\\+") ~ ((.data[[e2]] - .data[[e1]]) * (.data[[l2]] + .data[[l1]]) / 2) + ((.data[[l2]] + .data[[l1]]) * (((lead(.data[[l1]]) * lead(.data[[e1]])) / .data[[l1]]
      ) - ((lead(.data[[l2]]) * lead(.data[[e2]])) / .data[[l2]]
      )) / 2),
      TRUE ~ (.data[[e2]] - .data[[e1]]) * (.data[[l2]] + .data[[l1]]) / 2
    ),
    ## indirect ####
    indirect_effect = (((
      lead(.data[[e2]]) * (lead(.data[[l2]]) - (.data[[l2]] * lead(.data[[l1]])) /
        .data[[l1]])
    )
    -
      (
        lead(.data[[e1]]) * (lead(.data[[l1]]) - (.data[[l1]] * lead(.data[[l2]])) /
          .data[[l2]])
      ))
    / 2),
    ## exclusive ####
    exclusive_effect = case_when(
      !str_detect(.data[[age_col]], "\\+") ~ direct_effect + indirect_effect,
      TRUE ~ direct_effect
    ),
    interaction_effect = (lead(.data[[e2]]) - lead(.data[[e1]])) *
      (((((.data[[l1]] * lead(.data[[l2]])) / .data[[l2]]) + (.data[[l2]] * lead(.data[[l1]])) /
        .data[[l1]]
      )
      - (
          lead(.data[[l2]]) + lead(.data[[l1]])
        ))
      / 2),
    total_effect = case_when(
      !str_detect(.data[[age_col]], "\\+") ~ exclusive_effect + interaction_effect,
      TRUE ~ direct_effect
    )
    # ,
    # across(contains("effect"), ~ round(., 2))
  )
}
