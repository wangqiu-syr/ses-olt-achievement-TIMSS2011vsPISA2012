# Checks the comparison helper itself on toy numbers, so the suite runs
# something before any replication results exist.

test_that("compare_to_reported applies printed-precision tolerance", {
  ref <- data.frame(
    estimate_id = c("a", "b", "c", "d"),
    source = "toy", reported = c(0.25, 1.30, -0.12, 2.0),
    decimals = c(2, 2, 2, 1), tolerance = c(NA, NA, 0.05, NA),
    notes = NA, stringsAsFactors = FALSE
  )
  res <- data.frame(estimate_id = c("a", "b", "c"),
                    estimate = c(0.2549, 1.3051, -0.08))
  out <- compare_to_reported(res, ref)
  expect_equal(out$pass, c(TRUE, FALSE, TRUE, FALSE))
  expect_equal(out$found, c(TRUE, TRUE, TRUE, FALSE))
  expect_equal(out$tolerance, c(0.005, 0.005, 0.05, 0.05))
})

test_that("reference file template has the required columns", {
  ref <- read_reference(root_path("results", "paper_zhang_wang_2020.csv"))
  expect_true(all(c("estimate_id", "reported", "decimals", "tolerance") %in% names(ref)))
})
