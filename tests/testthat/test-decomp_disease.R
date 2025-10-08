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
