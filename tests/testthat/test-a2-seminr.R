# A2 cross-check: seminr (R) re-estimates of the SmartPLS models must reproduce SmartPLS's
# point estimates and its significance verdicts. Written by R/a2_04_seminr_crosscheck.R.

for (dir in c("a2", "a2_reading", "a2_science")) {
  test_that(paste("seminr reproduces the SmartPLS estimates in results", dir), {
    f <- root_path("results", dir, "a2_04_seminr_vs_smartpls.csv")
    skip_if_not(file.exists(f), paste("seminr cross-check not run for", dir))
    x <- utils::read.csv(f, stringsAsFactors = FALSE)
    expect_setequal(unique(x$run), c("M1_primary", "M1_escs", "M2_primary", "M2_escs"))
    point <- x[x$type %in% c("path", "tot", "ind", "r2", "loading", "alpha", "rhoc", "ave"), ]
    big <- point$estimate_id[abs(point$diff) >= 0.001]
    expect(length(big) == 0, paste("Point estimates differ by >= .001:", toString(big)))
    p <- x[x$type == "path", ]
    flip <- paste(p$run, p$estimate_id)[(p$smartpls_p < .05) != (p$seminr_p < .05)]
    expect(length(flip) == 0, paste("Significance verdict differs:", toString(flip)))
  })
}
