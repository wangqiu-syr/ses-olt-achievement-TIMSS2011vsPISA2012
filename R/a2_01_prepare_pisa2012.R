# A2 step 1: build school-level PISA 2012 (US) files that mimic Zhang & Wang (2020).
# Spec: docs/spec.md. Run from the project root:
#   Rscript R/a2_01_prepare_pisa2012.R
#
# Inputs  data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav   (user upload, gitignored)
# Outputs data/derived/a2_pisa2012_school.csv           all 162 schools + inclusion flags
#         data/derived/a2_smartpls_model1.csv           Model 1 (ICT use), complete cases
#         data/derived/a2_smartpls_model2.csv           Model 2 (ICT resources), complete cases
#         results/a2/a2_01_checks.csv                    data acceptance checks (spec D1-D5)
#         results/a2/a2_01_pisa2012_school_data.md       short data report
#         results/a2/data_manifest.csv                   raw-file provenance

suppressMessages(library(haven))

sav_path   <- "data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav"
min_otl_n  <- 10    # spec 2.3: minimum students with OTL data per school
us_math_published <- 481  # OECD (2013), PISA 2012 Results Vol. I: US mathematics mean

stopifnot(file.exists(sav_path))
dir.create("data/derived", showWarnings = FALSE, recursive = TRUE)
dir.create("results/a2", showWarnings = FALSE, recursive = TRUE)

# ---- helpers ---------------------------------------------------------------
num   <- function(x) as.numeric(zap_labels(x))
wmean <- function(x, w) { ok <- !is.na(x) & !is.na(w); if (!any(ok)) NA_real_ else sum(x[ok] * w[ok]) / sum(w[ok]) }
wsd   <- function(x, w) { ok <- !is.na(x); m <- wmean(x, w); sqrt(sum(w[ok] * (x[ok] - m)^2) / sum(w[ok])) }
wz    <- function(x, w) (x - wmean(x, w)) / wsd(x, w)
alpha <- function(m) { m <- m[stats::complete.cases(m), , drop = FALSE]; k <- ncol(m)
                       k / (k - 1) * (1 - sum(apply(m, 2, stats::var)) / stats::var(rowSums(m))) }
fmt   <- function(x, d = 2) formatC(x, format = "f", digits = d)

# ---- read ------------------------------------------------------------------
d <- read_sav(sav_path)
w <- num(d$W_FSTUWT)
pv <- paste0("PV", 1:5, "MATH")
pv_read <- paste0("PV", 1:5, "READ")   # exploratory: reading and science have no OTL items in PISA 2012
pv_scie <- paste0("PV", 1:5, "SCIE")
pv_crea <- paste0("PV", 1:5, "CREA")   # digital (computer-based) reading; exploratory, as READ/SCIE
pv_cmat <- paste0("PV", 1:5, "CMAT")   # computer-based math; exploratory
pv_cpro <- paste0("PV", 1:5, "CPRO")   # problem solving (computer-based); exploratory
pv_extra <- list(READ = pv_read, SCIE = pv_scie, CREA = pv_crea, CMAT = pv_cmat, CPRO = pv_cpro)
stopifnot(all(c(pv, unlist(pv_extra)) %in% names(d)))

# ---- student level ---------------------------------------------------------
# SES: mirrors the TIMSS composite (books, parent education, home possessions).
# Weighted z-scores (US 15-year-old population); mean of available parts if >= 2 of 3.
z_books   <- wz(num(d$ST28Q01), w)
z_hisced  <- wz(num(d$HISCED),  w)
z_homepos <- wz(num(d$HOMEPOS), w)
zz <- cbind(z_books, z_hisced, z_homepos)
ses_raw <- ifelse(rowSums(!is.na(zz)) >= 2, rowMeans(zz, na.rm = TRUE), NA_real_)
st <- data.frame(
  SCHOOLID = as.character(d$SCHOOLID),
  w        = w,
  SES      = wz(ses_raw, w),
  ESCS     = num(d$ESCS),
  OTL      = num(d$FAMCONC),
  sapply(c(pv, unname(unlist(pv_extra))), function(v) num(d[[v]]))
)
# Alternative OTL measures without FAMCONC (exploratory; the spec's OTL stays FAMCONC).
# ST73-76 ("OTL" items in the file): how often students meet 4 problem types (algebraic word
# problems, procedural tasks, pure and applied reasoning) in lessons (Q01) and tests (Q02).
# 1 = frequently ... 4 = never, reversed so higher = more often; mean of >= 6 of the 8 items.
pt_items <- paste0("ST7", rep(3:6, each = 2), "Q0", 1:2)
pt <- sapply(pt_items, function(v) 5 - num(d[[v]]))
colnames(pt) <- paste0("PT_", pt_items)
st <- cbind(st, pt)
st$OTL_PT  <- ifelse(rowSums(!is.na(pt)) >= 6, rowMeans(pt, na.rm = TRUE), NA_real_)
st$EXPUREM <- num(d$EXPUREM)   # PISA index: experience with pure-math tasks at school (ST61)
st$EXAPPLM <- num(d$EXAPPLM)   # PISA index: experience with applied-math tasks at school (ST61)

# ---- school level ----------------------------------------------------------
sch_vars <- c("SC13Q01", "SC13Q02", "SC13Q03", "SC14Q07", "SC14Q08", "SC14Q09",
              "RATCMP15", "cSC40Q01", "W_FSCHWT")
const_ok <- all(tapply(seq_len(nrow(d)), d$SCHOOLID, function(i)
  all(vapply(sch_vars, function(v) length(unique(num(d[[v]][i]))) == 1, logical(1)))))

by_sch <- split(seq_len(nrow(d)), st$SCHOOLID)
sch <- do.call(rbind, lapply(names(by_sch), function(id) {
  i <- by_sch[[id]]; s <- st[i, ]
  out <- data.frame(
    SCHOOLID = id,
    n_students = length(i),
    n_ses  = sum(!is.na(s$SES)),
    n_otl  = sum(!is.na(s$OTL)),
    SES    = wmean(s$SES,  s$w),
    ESCS   = wmean(s$ESCS, s$w),
    OTL    = wmean(s$OTL,  s$w),
    n_otl_pt = sum(!is.na(s$OTL_PT)),
    OTL_PT  = wmean(s$OTL_PT,  s$w),
    EXPUREM = wmean(s$EXPUREM, s$w),
    EXAPPLM = wmean(s$EXAPPLM, s$w),
    sum_stu_wt = sum(s$w)
  )
  for (k in 1:5) out[[paste0("MATH", k)]] <- wmean(s[[pv[k]]], s$w)
  for (v in colnames(pt)) out[[v]] <- wmean(s[[v]], s$w)
  for (dom in names(pv_extra)) for (k in 1:5) out[[paste0(dom, k)]] <- wmean(s[[pv_extra[[dom]][k]]], s$w)
  for (v in sch_vars) out[[v]] <- num(d[[v]][i[1]])
  out
}))

# ICT indicators (spec 3). Model 1, ICT use: share of work needing internet (higher = more).
sch$ICTUSE_LESSON <- sch$SC13Q01
sch$ICTUSE_HOMEWK <- sch$SC13Q02
sch$ICTUSE_ASSIGN <- sch$SC13Q03
# Model 2, ICT resources: shortages reversed (higher = fewer shortages) + computers per student.
sch$ICTRES_COMP <- 5 - sch$SC14Q07
sch$ICTRES_NET  <- 5 - sch$SC14Q08
sch$ICTRES_SOFT <- 5 - sch$SC14Q09
sch$ICTRES_RATIO <- sch$RATCMP15
sch$MATHPOL <- ifelse(sch$cSC40Q01 == 1, 1, ifelse(sch$cSC40Q01 == 2, 0, NA))  # kept, not modelled

m1_items <- c("ICTUSE_LESSON", "ICTUSE_HOMEWK", "ICTUSE_ASSIGN")
m2_items <- c("ICTRES_COMP", "ICTRES_NET", "ICTRES_SOFT", "ICTRES_RATIO")
core     <- c("SES", "OTL", paste0("MATH", 1:5), "ESCS")

sch$enough_otl <- sch$n_otl >= min_otl_n
sch$in_m1 <- sch$enough_otl & stats::complete.cases(sch[, c(core, m1_items)])
sch$in_m2 <- sch$enough_otl & stats::complete.cases(sch[, c(core, m2_items)])

utils::write.csv(sch, "data/derived/a2_pisa2012_school.csv", row.names = FALSE)
keep <- c("SCHOOLID", "SES", "OTL", paste0("MATH", 1:5), "ESCS", "sum_stu_wt",
          paste0(rep(names(pv_extra), each = 5), 1:5),  # READ/SCIE/CREA/CMAT/CPRO: exploratory runs only
          "OTL_PT", "EXPUREM", "EXAPPLM")              # OTL without FAMCONC: exploratory runs only
# SmartPLS wants plain numeric CSV: comma-delimited, no quotes, numeric ID.
write_spls <- function(df, path) {
  df$SCHOOLID <- as.integer(df$SCHOOLID)
  num_cols <- vapply(df, is.double, logical(1))
  df[num_cols] <- lapply(df[num_cols], round, 6)
  utils::write.csv(df, path, row.names = FALSE, quote = FALSE)
}
write_spls(sch[sch$in_m1, c(keep, m1_items)], "data/derived/a2_smartpls_model1.csv")
write_spls(sch[sch$in_m2, c(keep, m2_items)], "data/derived/a2_smartpls_model2.csv")
stopifnot(!anyNA(sch[sch$in_m1 | sch$in_m2, keep]))  # SmartPLS rejects missing cells

# ---- checks (spec 6, D1-D5) ------------------------------------------------
math_mean <- mean(sapply(pv, function(v) wmean(num(d[[v]]), w)))
read_mean <- mean(sapply(pv_read, function(v) wmean(num(d[[v]]), w)))
scie_mean <- mean(sapply(pv_scie, function(v) wmean(num(d[[v]]), w)))
crea_mean <- mean(sapply(pv_crea, function(v) wmean(num(d[[v]]), w)))
cmat_mean <- mean(sapply(pv_cmat, function(v) wmean(num(d[[v]]), w)))
cpro_mean <- mean(sapply(pv_cpro, function(v) wmean(num(d[[v]]), w)))
r_ses_escs_sch <- stats::cor(sch$SES, sch$ESCS, use = "complete.obs")
r_ses_escs_stu <- stats::cor(st$SES, st$ESCS, use = "complete.obs")
min_beta <- function(n) round(2.486 / sqrt(n), 3)  # inverse square root rule (Kock & Hadaya, 2018)
# type "hard" must pass (tests enforce it); type "report" informs interpretation only.
checks <- data.frame(
  check    = c("D1_n_students", "D1_n_schools", "D2_weighted_math_mean",
               "D3_school_vars_constant", "D4_n_schools_model1", "D4_n_schools_model2",
               "D4_min_detectable_beta_model1", "D4_min_detectable_beta_model2",
               "D5_r_SES_ESCS_school", "D5_r_SES_ESCS_student",
               "D2_weighted_read_mean", "D2_weighted_scie_mean", "D2_weighted_crea_mean",
               "D2_weighted_cmat_mean", "D2_weighted_cpro_mean"),
  type     = c("hard", "hard", "hard", "hard", "report", "report", "report", "report", "hard", "report",
               "report", "report", "report", "report", "report"),
  value    = c(nrow(d), length(by_sch), round(math_mean, 2), const_ok,
               sum(sch$in_m1), sum(sch$in_m2), min_beta(sum(sch$in_m1)), min_beta(sum(sch$in_m2)),
               round(r_ses_escs_sch, 3), round(r_ses_escs_stu, 3),
               round(read_mean, 2), round(scie_mean, 2), round(crea_mean, 2),
               round(cmat_mean, 2), round(cpro_mean, 2)),
  expected = c("4978", "162", sprintf("%d +/- 1", us_math_published), "TRUE",
               "", "", "", "", ">= 0.90", "",
               "498 (published)", "497 (published)", "511 (published)",
               "498 (published)", "508 (published)"),
  pass     = c(nrow(d) == 4978, length(by_sch) == 162,
               abs(math_mean - us_math_published) <= 1, const_ok,
               NA, NA, NA, NA, r_ses_escs_sch >= 0.90, NA, NA, NA, NA, NA, NA)
)
utils::write.csv(checks, "results/a2/a2_01_checks.csv", row.names = FALSE)

# ---- provenance ------------------------------------------------------------
raw <- c(sav_path, "data/raw/docs/Zhang_Wang_2020.pdf", "data/raw/docs/Data_to_pull_out_from_PISA_2012.docx")
raw <- raw[file.exists(raw)]
sha <- vapply(raw, function(f) strsplit(system2("sha256sum", shQuote(f), stdout = TRUE), " ")[[1]][1], "")
utils::write.csv(data.frame(file = raw, bytes = file.size(raw), sha256 = unname(sha),
                            source = "user upload", received = "2026-11-19"),
                 "results/a2/data_manifest.csv", row.names = FALSE)

# ---- report ----------------------------------------------------------------
desc_vars <- c("SES", "ESCS", "OTL", "MATH1", m1_items, m2_items)
desc <- function(df) paste0("| ", desc_vars, " | ", fmt(colMeans(df[, desc_vars])), " | ",
                            fmt(apply(df[, desc_vars], 2, stats::sd)), " |")
m1 <- sch[sch$in_m1, ]; m2 <- sch[sch$in_m2, ]
comp <- function(df, items) rowMeans(scale(df[, items]))
cor_tab <- function(df, items, label) {
  x <- data.frame(SES = df$SES, OTL = df$OTL, ICT = comp(df, items), MATH = rowMeans(df[, paste0("MATH", 1:5)]))
  r <- stats::cor(x)
  c(sprintf("**%s** (n = %d schools)", label, nrow(df)), "",
    "| | SES | OTL | ICT | MATH |", "|---|---|---|---|---|",
    paste0("| ", rownames(r), " | ", apply(r, 1, function(z) paste(fmt(z), collapse = " | ")), " |"), "")
}
rep <- c(
  "# A2 step 1: PISA 2012 (US) school-level data",
  "", sprintf("Built by `R/a2_01_prepare_pisa2012.R` from `%s`. Spec: `docs/spec.md`.", basename(sav_path)), "",
  "## Checks", "", "Hard checks must pass; report rows inform interpretation (spec section 6).", "",
  "| Check | Type | Value | Expected | Pass |", "|---|---|---|---|---|",
  paste0("| ", checks$check, " | ", checks$type, " | ", checks$value, " | ", checks$expected, " | ",
         ifelse(is.na(checks$pass), "", checks$pass), " |"), "",
  "D4: with these sample sizes, school-level paths smaller than about |0.21| are unlikely to reach p < .05",
  "(80% power, inverse square root rule). The paper's significant TIMSS paths ranged from 0.09 to 0.69.",
  "D5: the SES composite omits parental occupation (HISEI) to mirror TIMSS, so it tracks ESCS less closely",
  "per student than the audit's 4-part composite (r = .95); at school level, the unit of analysis, r is high.", "",
  "## Sample", "",
  sprintf("- %d students in %d schools; median %d students per school.", nrow(d), length(by_sch), as.integer(stats::median(sch$n_students))),
  sprintf("- %d schools have fewer than %d students with OTL (FAMCONC) data and are excluded.", sum(!sch$enough_otl), min_otl_n),
  sprintf("- Model 1 (ICT use): %d schools. Model 2 (ICT resources): %d schools (complete cases).", nrow(m1), nrow(m2)),
  "- No restriction like the paper's \"teachers use computers\": every US school with data reports computers (RATCMP15 > 0).", "",
  "## School-level descriptives (Model 2 sample)", "", "| Variable | Mean | SD |", "|---|---|---|", desc(m2), "",
  "## School-level correlations (preview; ICT = mean of standardized items)", "",
  cor_tab(m1, m1_items, "Model 1, ICT use"), cor_tab(m2, m2_items, "Model 2, ICT resources"),
  "## Cronbach's alpha, school level", "",
  sprintf("- ICT use (3 items, Model 1 sample): %s", fmt(alpha(as.matrix(m1[, m1_items])))),
  sprintf("- ICT resources (3 shortage items + RATCMP15, Model 2 sample): %s", fmt(alpha(as.matrix(m2[, m2_items])))),
  sprintf("- ICT resources, 3 shortage items only: %s", fmt(alpha(as.matrix(m2[, m2_items[1:3]])))),
  sprintf("- Math, 5 PV school means: %s", fmt(alpha(as.matrix(m1[, paste0("MATH", 1:5)])), 3)),
  sprintf("- Correlation of RATCMP15 with the shortage composite: %s", fmt(stats::cor(m2$ICTRES_RATIO, comp(m2, m2_items[1:3])))),
  sprintf("- RATCMP15 range %s to %s (skewed; watch its loading).", fmt(min(m2$ICTRES_RATIO)), fmt(max(m2$ICTRES_RATIO))),
  "", "## OTL without FAMCONC (exploratory)", "",
  "The spec's OTL is FAMCONC (column `OTL`). The files also carry three measures that don't use it, all school means:",
  "- `OTL_PT`: ST73–76, how often students meet 4 problem types in lessons and tests (8 items, 1–4, higher = more often).",
  "- `EXPUREM` and `EXAPPLM`: PISA indices of experience with pure-math and applied-math tasks (ST61).", "",
  "| Sample | r math–OTL (FAMCONC) | r math–OTL_PT | r math–EXPUREM | r math–EXAPPLM | r OTL–OTL_PT | r OTL–EXPUREM | r OTL–EXAPPLM |",
  "|---|---|---|---|---|---|---|---|",
  vapply(list(list(m1, "Model 1"), list(m2, "Model 2")), function(z) { x <- z[[1]]; mth <- rowMeans(x[, paste0("MATH", 1:5)])
    paste0(sprintf("| %s (n = %d) | ", z[[2]], nrow(x)), paste(fmt(c(stats::cor(mth, x$OTL), stats::cor(mth, x$OTL_PT), stats::cor(mth, x$EXPUREM),
      stats::cor(mth, x$EXAPPLM), stats::cor(x$OTL, x$OTL_PT), stats::cor(x$OTL, x$EXPUREM), stats::cor(x$OTL, x$EXAPPLM))), collapse = " | "), " |") }, ""),
  "",
  sprintf("- Cronbach's alpha of the 8 ST73–76 school means (Model 1 sample): %s. Only the procedural-task items (ST74) track math (r = %s and %s).",
          fmt(alpha(as.matrix(m1[, colnames(pt)]))), fmt(stats::cor(m1$PT_ST74Q01, rowMeans(m1[, paste0("MATH", 1:5)]))),
          fmt(stats::cor(m1$PT_ST74Q02, rowMeans(m1[, paste0("MATH", 1:5)])))),
  sprintf("- Every school in both samples has at least %d students with ST73–76 data.", as.integer(min(sch$n_otl_pt[sch$in_m1 | sch$in_m2])))
)
writeLines(rep, "results/a2/a2_01_pisa2012_school_data.md")

hard <- checks$type == "hard"
cat(sprintf("Hard checks passed: %d of %d\n", sum(checks$pass[hard]), sum(hard)))
print(checks, row.names = FALSE)
