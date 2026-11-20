# Release layout: the report and the READMEs link only to files that exist, run_all.R names only
# scripts that exist, and the figure script writes where the report reads.

md_files <- function() {
  root <- root_path()
  top  <- file.path(root, c("README.md", "data/README.md", "R/README.md"))
  sub  <- unlist(lapply(c("report", "docs", "results"), function(d)
    list.files(file.path(root, d), pattern = "\\.md$", recursive = TRUE, full.names = TRUE)))
  c(top[file.exists(top)], sub)
}

test_that("relative links in the report and READMEs resolve to files", {
  broken <- character(0)
  for (f in md_files()) {
    txt   <- readLines(f, encoding = "UTF-8", warn = FALSE)
    links <- unlist(regmatches(txt, gregexpr("\\]\\(([^)[:space:]]+)\\)", txt)))
    links <- sub("^\\]\\((.*)\\)$", "\\1", links)
    links <- links[!grepl("^(https?:|mailto:|#)", links)]
    targets <- sub("#.*$", "", links)
    missing <- links[!file.exists(file.path(dirname(f), targets))]
    if (length(missing)) broken <- c(broken, paste0(sub(paste0(root_path(), "/"), "", f, fixed = TRUE), ": ", missing))
  }
  expect(length(broken) == 0, paste(c("Broken links:", broken), collapse = "\n  "))
})

test_that("run_all.R runs only scripts that exist, in step order", {
  src     <- readLines(root_path("R", "run_all.R"), warn = FALSE)
  scripts <- unique(unlist(regmatches(src, gregexpr("\"(R|tests)/[A-Za-z0-9_]+\\.R\"", src))))
  scripts <- gsub("\"", "", scripts)
  expect_true(length(scripts) >= 5)
  expect_true(all(file.exists(root_path(scripts))), info = paste(scripts[!file.exists(root_path(scripts))], collapse = ", "))
  steps <- scripts[grepl("^R/a2_", scripts)]
  expect_identical(steps, sort(steps))
})

test_that("the figure script writes the report's figures, and the report shows all five", {
  fig_src <- readLines(root_path("R", "a2_06_moderation_figures.R"), encoding = "UTF-8", warn = FALSE)
  expect_true(any(grepl("fig_dir <- \"report/figures\"", fig_src, fixed = TRUE)))
  written <- unique(unlist(regmatches(fig_src, gregexpr("fig[1-4]_[a-z_]+\\.png", fig_src))))
  expect_length(written, 4)
  report <- paste(readLines(root_path("report", "report.md"), encoding = "UTF-8", warn = FALSE), collapse = "\n")
  for (f in c("fig0_design_flowchart.png", written)) {
    expect_true(file.exists(root_path("report", "figures", f)), info = f)
    expect_true(grepl(paste0("(figures/", f, ")"), report, fixed = TRUE), info = f)
  }
})

test_that("the report's BibTeX holds one entry per reference in the report", {
  report <- readLines(root_path("report", "report.md"), encoding = "UTF-8", warn = FALSE)
  refs   <- report[seq(which(report == "## References"), length(report))]
  bib    <- readLines(root_path("report", "references.bib"), encoding = "UTF-8", warn = FALSE)
  expect_equal(sum(grepl("^@", bib)), sum(grepl("^- ", refs)))
})

test_that(".zenodo.json is valid enough for Zenodo and agrees with CITATION.cff", {
  zen <- root_path(".zenodo.json")
  skip_if_not(file.exists(zen), "no .zenodo.json")
  z   <- paste(readLines(zen, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  cff <- paste(readLines(root_path("CITATION.cff"), encoding = "UTF-8", warn = FALSE), collapse = "\n")
  # Zenodo reads one licence id, and uses .zenodo.json in place of CITATION.cff
  expect_match(z, "\"license\": \"(cc-by-4\\.0|mit)\"")
  title <- sub('^.*\ntitle: "([^"]+)".*$', "\\1", cff)
  expect_true(grepl(title, z, fixed = TRUE), info = "same title in both files")
  orcids <- regmatches(cff, gregexpr("[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{3}[0-9X]", cff))[[1]]
  expect_length(orcids, 2)
  for (o in orcids) expect_true(grepl(o, z, fixed = TRUE), info = o)
})
