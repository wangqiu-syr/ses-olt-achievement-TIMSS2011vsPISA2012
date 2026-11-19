# Helpers for checking replication estimates against numbers reported in a paper.
#
# Reference CSV (results/paper_*.csv), one row per reported number:
#   estimate_id  unique key, e.g. "T3_M1_math_SES" (table_model_outcome_term)
#   source       location in the paper, e.g. "Table 3, Model 1"
#   reported     the value as printed
#   decimals     decimals printed in the paper (sets the default tolerance)
#   tolerance    optional absolute tolerance; blank = half a unit in the last
#                printed digit, i.e. 0.5 * 10^-decimals
#   notes        free text
#
# Results CSV (written by the R/ scripts to results/), one row per estimate:
#   estimate_id, estimate[, se]

# Locate the project root whether tests run from the root or from tests/testthat.
root_path <- function(...) {
  dir <- normalizePath(getwd(), mustWork = TRUE)
  repeat {
    if (file.exists(file.path(dir, "renv.lock")) || dir.exists(file.path(dir, ".git"))) {
      return(file.path(dir, ...))
    }
    parent <- dirname(dir)
    if (identical(parent, dir)) stop("Project root not found from ", getwd())
    dir <- parent
  }
}

read_reference <- function(path) {
  ref <- utils::read.csv(path, stringsAsFactors = FALSE, comment.char = "#",
                         na.strings = c("", "NA"))
  required <- c("estimate_id", "source", "reported", "decimals", "tolerance", "notes")
  missing_cols <- setdiff(required, names(ref))
  if (length(missing_cols)) stop("Reference file lacks columns: ", toString(missing_cols))
  if (anyDuplicated(ref$estimate_id)) stop("Duplicate estimate_id in ", path)
  ref
}

default_tolerance <- function(decimals) 0.5 * 10^(-decimals)

# Returns one row per reference estimate, with the replicated value, the
# absolute difference, the tolerance used, and pass/fail.
compare_to_reported <- function(results, reference) {
  tol <- ifelse(is.na(reference$tolerance),
                default_tolerance(reference$decimals),
                reference$tolerance)
  idx <- match(reference$estimate_id, results$estimate_id)
  estimate <- results$estimate[idx]
  diff <- abs(estimate - reference$reported)
  data.frame(
    estimate_id = reference$estimate_id,
    reported    = reference$reported,
    estimate    = estimate,
    abs_diff    = diff,
    tolerance   = tol,
    found       = !is.na(idx),
    pass        = !is.na(diff) & diff <= tol + 1e-12,
    stringsAsFactors = FALSE
  )
}
