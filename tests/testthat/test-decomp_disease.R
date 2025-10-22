## input validation ------------------------------------------------------------

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

test_that("decomp_disease errors on one disease element not found in groups", {
  expect_error(
    decomp_disease(india_china_males_1990[, -3],
      breakdown = "proportion", diseases = c("CD", "NCD", "Injuries"),
      group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
      group_2_m = "China_nmx", nDx = "nDx"
    ),
    "One or more diseases not found in groups"
  )
})

## calculations validation -----------------------------------------------------

test_that("calculates delta correctly for raw breakdown", {
  result <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", diseases = c("CD"),
    group_1 = "India", group_1_m = "India_nmx",
    group_2 = "China", group_2_m = "China_nmx", nDx = "nDx"
  )
  expected <- with(india_china_males_1990, nDx * (China_CD - India_CD) / (China_nmx - India_nmx))
  expect_equal(result$delta_CD, expected)
})


## output validation -----------------------------------------------------------

test_that("decomp_disease valid output", {
  result <- decomp_disease(india_china_males_1990,
    breakdown = "proportion", diseases = c("CD", "NCD", "Injuries"),
    group_1 = "India", group_1_m = "India_nmx", group_2 = "China",
    group_2_m = "China_nmx", nDx = "nDx"
  )
  expect_s3_class(result, "data.frame")
  expect_true(all(c("delta_CD", "delta_NCD", "delta_Injuries") %in% colnames(result)))
})
