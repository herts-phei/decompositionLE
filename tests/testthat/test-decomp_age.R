## input validation ------------------------------------------------------------

test_that("checks input is in correct format", {
  df_test_fct <- us_females
  df_test_fct$Age <- as.character(us_females$Age)
  expect_error(decomp_age(df_test_fct,
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ))
  df_test_prop <- us_females
  df_test_prop$l1x[1] <- 2
  expect_error(decomp_age(df_test_prop,
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ))
  df_test_num <- us_females
  df_test_num$l2x <- as.character(df_test_num$l2x)
  expect_error(decomp_age(df_test_num,
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ))
})

test_that("checks that example data matches the paper", {
  ponnapalli_arriaga3_results <- data.frame(
    Age = c("0", "5", "15", "25", "45", "65", "85+"),
    direct_effect = c(0.22, 0.06, 0.08, 0.58, 1.18, 2.55, 0.57),
    indirect_effect = c(3.63, 0.67, 0.94, 1.99, 2.19, 1.18, NA),
    exclusive_effect = c(3.85, 0.73, 1.02, 2.57, 3.37, 3.73, 0.57),
    interaction_effect = c(0.00, -0.00, -0.01, -0.02, -0.06, -0.07, NA),
    total_effect = c(3.85, 0.73, 1.01, 2.55, 3.31, 3.66, 0.57)
  ) |>
    tibble::as_tibble()

  df_test <- decomp_age(us_females |> filter(Age %in% c("0", "5", "15", "25", "45", "65", "85+")),
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ) |>
    dplyr::group_by(Age) |>
    dplyr::summarise(
      dplyr::across(dplyr::everything(), ~ round(.x, digits = 2))
    ) |>
    dplyr::ungroup() %>%
    dplyr::select(Age, direct_effect, indirect_effect, exclusive_effect, interaction_effect, total_effect) |>
    dplyr::mutate(Age = as.character(Age))

  expect_equal(df_test, ponnapalli_arriaga3_results, tolerance = 0.1)
})
