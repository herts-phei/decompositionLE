## input validation ------------------------------------------------------------

test_that("decomp_disease errors on invalid breakdown", {
  expect_error(
    decomp_disease(india_china_males_1990,
      breakdown = "qwerty", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
      group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
      group_2_m = "China_nmx", nDx = "nDx"
    ),
    "Invalid breakdown argument selected"
  )
})

test_that("checks input is in correct format", {
  df_test_fct <- india_china_males_1990
  df_test_fct$Age <- as.character(india_china_males_1990$Age)
  expect_error(decomp_disease(df_test_fct,
    breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ))
  df_test_num <- india_china_males_1990
  df_test_num$India_nmx <- as.character(df_test_num$India_nmx)
  expect_error(decomp_disease(df_test_num,
    breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ))
  df_test_prop <- india_china_males_1990
  df_test_prop$India_CD[1] <- 99999
  expect_error(decomp_disease(df_test_prop,
    breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ), regexp = "The following group-age combinations do not sum to 1 within tolerance of 0.01")
})

test_that("checks that example data matches the paper", {
  preston_box4.3_results <- data.frame(
    Age = forcats::as_factor(c("0", "5", "15", "30", "45", "60", "70+")),
    delta_CD = c(5.5, 0.6, 0.4, 0.6, 0.7, 0.5, 0.7),
    delta_NCD = c(0.1, 0.1, -0.1, -0.1, 0, -0.1, -0.9),
    delta_Injuries = c(-0.0, 0.2, -0, 0.1, 0.1, -0, -0.1)
  )

  df_test <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  ) |>
    select(Age, delta_CD, delta_NCD, delta_Injuries)

  expect_equal(df_test, preston_box4.3_results, tolerance = 0.2)
})

## calculations validation -----------------------------------------------------

test_that("calculates delta correctly for raw breakdown", {
  result <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", age_col = "Age", diseases = c("CD"),
    group_1 = "India", group_1_m = "India_nmx",
    group_2 = "China", group_2_m = "China_nmx", nDx = "nDx"
  )
  expected <- with(india_china_males_1990, nDx * ((China_CD * China_nmx) - (India_CD * India_nmx)) / (China_nmx - India_nmx))
  expect_equal(result$delta_CD, expected)
})

## output validation -----------------------------------------------------------

test_that("decomp_disease valid output", {
  result <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", age_col = "Age", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(c("delta_CD", "delta_NCD", "delta_Injuries") %in% colnames(result)))
})
