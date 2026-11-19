# Phase A1: replicated TIMSS 2011 estimates must match Zhang & Wang (2020).
# Skips until (1) reported values are entered in the reference CSV and
# (2) the R/ pipeline has written the A1 results file.

ref_file <- root_path("results", "paper_zhang_wang_2020.csv")
res_file <- root_path("results", "a1", "a1_timss2011_estimates.csv")

test_that("A1 estimates reproduce Zhang & Wang (2020) reported values", {
  ref <- read_reference(ref_file)
  skip_if(nrow(ref) == 0, "No reported values entered yet in results/paper_zhang_wang_2020.csv")
  skip_if_not(file.exists(res_file), "A1 results not produced yet (results/a1/a1_timss2011_estimates.csv)")

  res <- utils::read.csv(res_file, stringsAsFactors = FALSE)
  out <- compare_to_reported(res, ref)

  expect(all(out$found),
         paste("Missing from results:", toString(out$estimate_id[!out$found])))
  failed <- out[out$found & !out$pass, ]
  expect(nrow(failed) == 0,
         paste0("Outside tolerance:\n",
                paste(utils::capture.output(print(failed, row.names = FALSE)), collapse = "\n")))
})
