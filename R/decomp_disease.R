#' Title decomp_disease
#'
#' Function for performing life expectancy decomposition for disease groups
#'
#' @param df An outputted life table with relevant columns of interest
#' @param breakdown Whether disease breakdowns are raw mortality rates or a decimal proportion of total all-cause mortality rate. Accepts either 'proportion' or 'raw'.
#' @param age_col Column providing ordered age bands with the final age group being an open-ended interval suffxied with '+', e.g. '90+'.. Of factor type.
#' @param diseases Character vector of diseases which are suffixed to `group_1` and `group_2`, and found in both groups. There should be no other characters after these diseases for the function to capture the group-disease combinations.
#' @param group_1 Unique matching stem prefix in columns for group 1 related disease cause breakdowns
#' @param group_1_m Column name for group 1 all-cause mortality rate between ages x and x + n
#' @param group_2 Unique matching stem prefix in columns for group 2 related disease cause breakdowns
#' @param group_2_m Column name for group 2 all-cause mortality rate between ages x and x + n
#' @param nDx Column name for contribution of all-cause mortality differences in groups 1 and 2 in age groups x to x + n. Computationally the same as the total effect column computed from `decomp_LE()`.
#' @returns A data frame with life expectancy disease breakdown decomposition values
#' @export
#'
#' @examples
#' decomp_disease(india_china_males_1990,
#'   breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
#'   group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
#'   group_2_m = "China_nmx", nDx = "nDx"
#' )
#'
#' @importFrom stringr str_detect
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate case_when lead select starts_with everything all_of
#' @importFrom tidyr pivot_wider pivot_longer ends_with
#' @importFrom purrr map map_lgl

decomp_disease <- function(df, breakdown, diseases, age_col, group_1, group_1_m, group_2, group_2_m, nDx) {
  if (!is.factor(df[[age_col]])) stop("The age column is not of type factor")

  age_band_logical <- levels(df[[age_col]]) |>
    as.vector() |>
    str_detect("\\+")

  if (age_band_logical |> sum() == 0) stop("No open-ended age band found. The last level must be the sole open-ended age band suffixed with '+'")
  if (age_band_logical |> sum() > 1) stop("More than one open age band found. The last level must be the sole open age band suffixed with '+'")
  if (isFALSE(age_band_logical[length(age_band_logical)] && sum(age_band_logical) == 1)) stop("The last age band is not open-ended. Another age band is open-ended.")

  if (!breakdown %in% c("proportion", "raw")) stop("Invalid breakdown argument selected")

  df_colnames <- colnames(df)

  countries <- c(group_1, group_2)

  catch <- countries |>
    map(~ paste0("^", .x, "(_)?", diseases, "$", recycle0 = T)) |>
    unlist()

  all_combinations_in_colnames_check <- all(map_lgl(catch, ~ any(str_detect(df_colnames, .x))))

  if (isFALSE(all_combinations_in_colnames_check)) stop("One or more diseases not found in groups")

  required_numeric_cols <- c(paste(catch, collapse = "|") |> grep(names(df), value = TRUE), group_1_m, group_2_m, nDx)
  non_numeric <- required_numeric_cols[!sapply(df[required_numeric_cols], is.numeric)]

  if (length(non_numeric)) {
    stop(sprintf("The following columns are not numeric: %s", paste(non_numeric, collapse = ", ")), call. = FALSE)
  }

  intermediate <- df |>
    pivot_longer(
      cols = all_of(c(starts_with(group_1), starts_with(group_2))) & !all_of(c(group_1_m, group_2_m)) & all_of(ends_with(diseases)),
      names_to = c(".value", "disease"),
      names_pattern = paste0("^(", group_1, "|", group_2, ")(.*)$")
    )

  if (breakdown == "proportion") {
    proportions_transform <- intermediate |>
      pivot_wider(id_cols = "disease", names_from = all_of(age_col), values_from = all_of(c(group_1, group_2)))

    colsums <- colSums(proportions_transform[, !(names(proportions_transform) %in% "disease")])
    not_close <- names(colsums)[!sapply(colsums, function(x) isTRUE(all.equal(x, 1, tolerance = 0.01)))]

    if (length(not_close) > 0) {
      stop(paste("The following group-age combinations do not sum to 1 within tolerance of 0.01:", paste(not_close, collapse = ", ")))
    }
  }


  intermediate |>
    mutate(delta = case_when(
      breakdown == "raw" ~ (.data[[nDx]] * (.data[[group_2]] - .data[[group_1]]) / (.data[[group_2_m]] - .data[[group_1_m]])),
      breakdown == "proportion" ~ (.data[[nDx]] * ((.data[[group_2]] * .data[[group_2_m]]) - (.data[[group_1]] * .data[[group_1_m]])) / (.data[[group_2_m]] - .data[[group_1_m]]))
    )) |>
    pivot_wider(
      names_from = "disease", values_from = c(group_2, group_1, "delta"),
      names_glue = "{.value}{disease}"
    ) |>
    select(df_colnames, everything()) |>
    suppressWarnings() |>
    as.data.frame() |> # strip S3 class
    identity()
}
