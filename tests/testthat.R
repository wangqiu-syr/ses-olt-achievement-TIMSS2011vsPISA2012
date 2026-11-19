# Run the test suite from the project root:
#   Rscript tests/testthat.R
# Replication tests skip (rather than fail) until their inputs exist.
library(testthat)
test_dir(file.path("tests", "testthat"), stop_on_failure = TRUE)
