#' Title decomp_age
#'
#' Function for performing life expectancy decomposition for age bands
#'
#' @param df An outputted life table with columns for age bands, number of persons alive at each age band and expectation of life at each age band
#' @param method Methods to use for life expectancy decomposition. Defaults to 'arriaga3'. Current methods available are: 'arriaga3'.
#' @param age_col Column providing ordered age bands with the final age group being an open-ended interval suffxied with '+', e.g. '90+'.. Of factor type.
#' @param e1 Column name for expectation of life at age group x, in the 1st group of comparison.
#' @param e2 Column name for expectation of life at age group x, in the 2nd group of comparison.
#' @param l1 Column name for The number of persons alive at age group x, in the 1st group of comparison.
#' @param l2 Column name for The number of persons alive at age group x, in the 2nd group of comparison.
#' @param append Whether to append the decomposition columns to the original data frame.
#'
#' @returns A data frame with attached life expectancy decomposition values
#' @export
#'
#' @examples
#' decomp_age(us_females,
#'   method = "arriaga3", age_col = "Age", e1 = "e1x",
#'   e2 = "e2x", l1 = "l1x", l2 = "l2x"
#' )
#' @importFrom stringr str_detect
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate case_when lead

decomp_age <- function(df, method = "arriaga3", age_col, e1, e2, l1, l2, append = TRUE) {
  if (!is.factor(df[[age_col]])) stop("The age column is not of type factor")

  methods <- c("arriaga3", "pollards3")

  if (!method %in% methods) stop("Invalid method")

  age_band_logical <- levels(df[[age_col]]) |>
    as.vector() |>
    stringr::str_detect("\\+")

  if (age_band_logical |> sum() == 0) stop("No open-ended age band found. The last level must be the sole open-ended age band suffixed with '+'")
  if (age_band_logical |> sum() > 1) stop("More than one open age band found. The last level must be the sole open age band suffixed with '+'")
  if (isFALSE(age_band_logical[length(age_band_logical)] && sum(age_band_logical) == 1)) stop("The last age band is not open-ended. Another age band is open-ended.")

  result <- suppressWarnings(
    switch(method,
      arriaga3 = .arriaga3(df, age_col, e1, e2, l1, l2),
      pollards3 = .pollards3(df, age_col, nm1x = "nm1x", l1x = "l1x", e1x = "e1x", nm2x = "nm2x", l2x = "l2x", e2x = "e2x")
    )
  )

  result
}

decomp_age(us_females,
  method = "arriaga3", age_col = "Age", e1 = "e1x",
  e2 = "e2x", l1 = "l1x", l2 = "l2x"
)

.arriaga3 <- function(df, age_col, e1, e2, l1, l2) {
  df |> mutate(
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

## method = pollard III

## us_females
library(dplyr)

.pollards3 <- function(df, age_col, nm1x, l1x, e1x, nm2x, l2x, e2x) {
  n <- nrow(df)

  # Add interval width (5-year intervals)
  df <- df %>%
    dplyr::filter(df[[age_col]] %in% c(0, 5, 15, 25, 45, 65, "85+")) %>%
    dplyr::mutate(interval_width = dplyr::case_when(
      .data[[age_col]] == "85+" ~ 10,
      TRUE ~ 5
    ))

  # Create next age group values
  df <- dplyr::mutate(df,
    lx1_next = c(.data[[l1x]][-1], utils::tail(.data[[l1x]], 1)),
    ex1_next = c(.data[[e1x]][-1], utils::tail(.data[[e1x]], 1)),
    lx2_next = c(.data[[l2x]][-1], utils::tail(.data[[l2x]], 1)),
    ex2_next = c(.data[[e2x]][-1], utils::tail(.data[[e2x]], 1))
  )

  # Pollards III method
  df <- dplyr::mutate(df,
    exclusive_effect = (.data[[nm1x]] - .data[[nm2x]]) *
      0.5 * ((.data[[l1x]] * .data[[e1x]]) + (.data[[l2x]] * .data[[e2x]])),
    interaction_effect =
      (.data[[nm1x]] - .data[[nm2x]]) *
        ((.data[[e2x]] - .data[[e1x]]) * (.data[[l1x]] - .data[[l2x]])),
    total_effect = .data$exclusive_effect + .data$interaction_effect
  )

  output <- dplyr::select(df,
    age = dplyr::all_of(age_col),
    exclusive_effect,
    interaction_effect,
    total_effect
  )

  total_row <- tibble::tibble(
    age = "Total",
    exclusive_effect = sum(output$exclusive_effect, na.rm = TRUE),
    interaction_effect = sum(output$interaction_effect, na.rm = TRUE),
    total_effect = sum(output$total_effect, na.rm = TRUE)
  )

  output <- dplyr::bind_rows(output, total_row)

  return(output)
}

test <- decomp_age(
  us_females,
  method = "pollards3",
  age_col = "Age"
)
