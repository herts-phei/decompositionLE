#' Title decomposition
#'
#' description Function for performing life expectancy decomposition.
#'
#' @param df An outputted life table with
#' @param method Methods to use for life expectancy decomposition. Defaults to 'arriaga3'. Current methods available are: 'arriaga3', 'arriaga2'. Future available methods will include:
#' @param age_col Column providing ordered age bands. Of factor type.
#' @param e1 Expectation of life at age group x, in the first group of comparison.
#' @param e2 Expectation of life at age group x, in the first group of comparison.
#' @param l1 Expectation of life at age group x, in the first group of comparison.
#' @param l2 Expectation of life at age group x, in the first group of comparison.
#'
#'
#' @returns
#' @export
#'
#' @examples
decomposition <- function(df, method, age_col, e1, e2, l1, l2, append = TRUE) {


  if (is.factor(df[["AgeGroup"]])) stop("The age column is not of type factor")
  if (levels(df[["AgeGroup"]]) |> as.vector() |> str_detect("\\+") |> sum() == 0) stop("")


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
