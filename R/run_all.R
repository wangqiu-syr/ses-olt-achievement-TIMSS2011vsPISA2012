# Run every automated step of the analysis, in order, then the tests. From the repository root:
#   Rscript R/run_all.R
#
# Needs the PISA 2012 file at data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav (see data/README.md)
# and the packages in renv.lock (see R/README.md). About 35 minutes on 4 cores, most of it step 5.
#
# Environment:
#   NBOOT      bootstrap samples for steps 2-6 (default 5000, as in the report). NBOOT=200 gives a
#              quick check of the pipeline; its numbers are not the report's.
#   FROM, TO   run only steps FROM to TO, e.g. FROM=6 to redraw the figures from the committed grid.
#   DRY_RUN=1  list the steps without running them.
#
# Not automated (optional): the SmartPLS 4 runs and R/a2_02_read_smartpls.R, which reads their exports
# (docs/a2_smartpls_steps.md). Their outputs are committed (results/a2*/a2_pisa2012_estimates_*.csv and
# a2_02_criteria.csv), so the steps below run without SmartPLS.

steps <- data.frame(
  script = c("R/a2_01_prepare_pisa2012.R",
             "R/a2_04_seminr_crosscheck.R", "R/a2_04_seminr_crosscheck.R", "R/a2_04_seminr_crosscheck.R",
             "R/a2_05_seminr_runs.R",
             "R/a2_06_moderation_figures.R",
             "tests/testthat.R"),
  arg    = c("", "math", "reading", "science", "", "", ""),
  what   = c("School-level files and data checks D1-D5 (data/derived/, results/a2/)",
             "seminr re-estimates the SmartPLS math runs (results/a2/)",
             "seminr re-estimates the SmartPLS print reading runs (results/a2_reading/)",
             "seminr re-estimates the SmartPLS science runs (results/a2_science/)",
             "Exploratory grid, 96 runs (results/a2_seminr/)",
             "Report figures 1-4 and moderation statistics (report/figures/, results/a2_seminr/)",
             "Test suite"),
  stringsAsFactors = FALSE)
steps$step <- seq_len(nrow(steps))

if (!file.exists("renv.lock") || !dir.exists("R")) stop("Run from the repository root: Rscript R/run_all.R")
from <- as.integer(Sys.getenv("FROM", "1"))
to   <- as.integer(Sys.getenv("TO", as.character(nrow(steps))))
todo <- steps[steps$step >= from & steps$step <= to, ]

cat(sprintf("Steps %d-%d of %d; NBOOT = %s\n", from, to, nrow(steps), Sys.getenv("NBOOT", "5000 (default)")))
for (i in seq_len(nrow(todo))) with(todo[i, ], cat(sprintf("  %d. %s %s  %s\n", step, script, arg, what)))
if (Sys.getenv("DRY_RUN") == "1") quit(save = "no")

# Step 1 reads the PISA file; steps 2-6 read the school files that step 1 writes.
sav     <- "data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav"
derived <- "data/derived/a2_smartpls_model1.csv"
if (1 %in% todo$step && !file.exists(sav))
  stop("Missing ", sav, ". data/README.md says how to obtain it.")
if (!1 %in% todo$step && any(todo$step %in% 2:6) && !file.exists(derived))
  stop("Missing ", derived, ". Run step 1 first (FROM=1).")

rscript <- file.path(R.home("bin"), "Rscript")
times <- numeric(0)
for (i in seq_len(nrow(todo))) {
  s <- todo[i, ]
  cat(sprintf("\n==== Step %d: %s %s\n", s$step, s$script, s$arg))
  t0 <- Sys.time()
  status <- system2(rscript, c(s$script, if (nzchar(s$arg)) s$arg))
  times[i] <- as.numeric(difftime(Sys.time(), t0, units = "mins"))
  if (status != 0) stop(sprintf("Step %d (%s %s) failed with status %d", s$step, s$script, s$arg, status))
}

cat("\n==== Done\n")
for (i in seq_len(nrow(todo))) cat(sprintf("  %d. %-32s %-8s %6.1f min\n", todo$step[i], todo$script[i], todo$arg[i], times[i]))
cat(sprintf("  Total %.1f min on %d cores. %s\n", sum(times), parallel::detectCores(), R.version.string))
