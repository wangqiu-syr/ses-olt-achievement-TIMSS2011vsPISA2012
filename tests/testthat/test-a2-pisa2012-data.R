# A2 step 1: the school-level PISA data build must pass the hard data checks
# in docs/spec.md section 6 (D1-D3, D5). Written by R/a2_01_prepare_pisa2012.R.

checks_file <- root_path("results", "a2", "a2_01_checks.csv")

test_that("A2 data build passes all hard checks", {
  skip_if_not(file.exists(checks_file), "A2 data build not run yet (results/a2/a2_01_checks.csv)")
  ch <- utils::read.csv(checks_file, stringsAsFactors = FALSE)
  hard <- ch[ch$type == "hard", ]
  expect_setequal(hard$check, c("D1_n_students", "D1_n_schools", "D2_weighted_math_mean",
                                "D3_school_vars_constant", "D5_r_SES_ESCS_school"))
  failed <- hard[!as.logical(hard$pass), ]
  expect(nrow(failed) == 0, paste("Failed hard checks:", toString(failed$check)))
})
