test_that("decomp_disease errors on invalid breakdown", {
  expect_error(
    decomp_disease(india_china_males_1990,
      breakdown = "qwerty", diseases = c("CD", "NCD", "Injuries"),
      group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
      group_2_m = "China_nmx", nDx = "nDx"
    ),
    "Invalid breakdown argument selected"
  )
})

test_that("decomp_disease valid output", {
  expect_s3_class(
    decomp_disease(india_china_males_1990,
      breakdown = "proportion", diseases = c("CD", "NCD", "Injuries"),
      group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
      group_2_m = "China_nmx", nDx = "nDx"
    ),
    "data.frame"
  )
})

test_that("checks input is in correct format", {
  df_test_fct <- india_china_males_1990
  df_test_fct$Age <- as.character(india_china_males_1990$Age)
  expect_error(decomp_disease(india_china_males_1990,
    breakdown = "proportion", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ))
  df_test_prop <- india_china_males_1990
  df_test_prop$l1x[1] <- 2
  expect_error(decomp_age(df_test_prop,
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ))
  df_test_num <- india_china_males_1990
  df_test_num$l2x <- as.character(df_test_num$l2x)
  expect_error(decomp_age(df_test_num,
    method = "arriaga3", age_col = "Age",
    e1 = "e1x", e2 = "e2x", l1 = "l1x", l2 = "l2x"
  ))
  # TODO Add check that row props equal 1
})

test_that("checks that example data matches the paper", {
  preston_box4.3_results <- data.frame(
    Age = forcats::as_factor(c("0", "5", "15", "30", "45", "60", "70+")),
    delta_CD = c(5.5, 0.6, 0.4, 0.6, 0.7, 0.5, 0.7),
    delta_NCD = c(0.1, 0.1, -0.1, -0.1, 0, -0.1, -0.9),
    delta_Injuries = c(-0.0, 0.2, -0, 0.1, 0.1, -0, -0.1)
  )

  df_test <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ) |>
    select(Age, delta_CD, delta_NCD, delta_Injuries)

  expect_equal(df_test, preston_box4.3_results, tolerance = 0.2)
})
