# A2 moderation figures (exploratory), from the seminr grid (R/a2_05). Run from the project root:
#   Rscript R/a2_06_moderation_figures.R
#
# Fig 1  SES x ICT on achievement, every outcome x OTL measure, both ICT models (primary runs)
# Fig 2  Simple slopes of SES -> achievement at low / mean / high ICT, for the focal cell (the
#        outcome x model with the most significant SES x ICT results) beside its paper/computer
#        counterpart. Bootstrap CIs for each slope.
# Fig 3  Robustness of the focal moderation: four OTL measures x SES composite vs. ESCS
# Fig 4  OTL -> achievement by OTL measure: how much OTL's role depends on its measure
#
# Inputs  results/a2_seminr/estimates.csv (a2_05); data/derived/a2_smartpls_model{1,2}.csv (a2_01)
# Outputs report/figures/fig{1..4}_*.png (the report's figures); results/a2_seminr/simple_slopes.csv and
#         moderation_stats.csv (f², Benjamini–Hochberg q)
# NBOOT (default 5000) sets the bootstrap for the two refits behind Fig 2.

# Labels use ×, → and −: read and draw them as UTF-8 even where the session locale is C/POSIX.
invisible(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
source("R/a2_seminr_helpers.R", encoding = "UTF-8")
suppressMessages(library(ggplot2))
nboot <- as.integer(Sys.getenv("NBOOT", "5000"))
fig_dir <- "report/figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
est <- utils::read.csv("results/a2_seminr/estimates.csv", stringsAsFactors = FALSE)

outc <- data.frame(outcome = c("math", "reading", "science", "digital", "cmat", "cpro"),
                   lv = c("MATH", "READ", "SCIE", "CREA", "CMAT", "CPRO"),
                   label = c("Math", "Print reading", "Science", "Digital reading", "Computer-based math", "Problem solving"),
                   mode = rep(c("Paper-based test", "Computer-based test"), each = 3),
                   counterpart = c("cmat", "digital", "math", "reading", "math", "math"), stringsAsFactors = FALSE)
otl_lab   <- c(famconc = "FAMCONC", pt = "OTL_PT", expurem = "EXPUREM", exapplm = "EXAPPLM")
model_lab <- c(M1 = "Model 1: ICT use", M2 = "Model 2: ICT resources")
olab <- function(o) outc$label[match(o, outc$outcome)]

# Palette: validated reference instance (dataviz skill), light surface. Paper/computer = slots 1/2;
# ordinal ICT levels = one-hue blue ramp (steps 250/450/650).
surface <- "#fcfcfb"; ink <- "#0b0b0b"; ink2 <- "#52514e"; gridc <- "#e7e6e2"
blue <- "#2a78d6"; orange <- "#eb6834"
mode_cols <- c("Paper-based test" = blue, "Computer-based test" = orange)
font <- "Inter"   # has the ×, →, − and · glyphs; rendered with ragg
update_geom_defaults("text", list(family = font))
theme_viz <- theme_minimal(base_size = 10, base_family = font) + theme(
  plot.background = element_rect(fill = surface, colour = NA), panel.background = element_rect(fill = surface, colour = NA),
  panel.grid.minor = element_blank(), panel.grid.major.y = element_blank(),
  panel.grid.major.x = element_line(colour = gridc, linewidth = .3),
  text = element_text(colour = ink), axis.text = element_text(colour = ink2), axis.title = element_text(colour = ink2),
  strip.text = element_text(face = "bold", hjust = 0, colour = ink), legend.position = "top", legend.justification = "left",
  legend.title = element_blank(), plot.title.position = "plot", plot.title = element_text(face = "bold", size = 12),
  plot.subtitle = element_text(colour = ink2), plot.caption = element_text(colour = ink2, hjust = 0, size = 8),
  plot.caption.position = "plot")
sig_shapes <- c("p < .05" = 16, "not significant" = 21)
nz <- function(x) sub("^(-?)0\\.", "\\1.", formatC(x, format = "f", digits = 2))
save <- function(p, name, w, h) ggsave(file.path(fig_dir, name), p, width = w, height = h, dpi = 200,
                                       bg = surface, device = ragg::agg_png)

# ---- Fig 1: SES x ICT everywhere ----------------------------------------------------------
m <- est[est$id == "path_SESxICT_ACH" & est$ses == "primary", ]
row_levels <- rev(unlist(lapply(outc$outcome, function(o) paste0(olab(o), " · ", otl_lab))))
m$row   <- factor(paste0(olab(m$outcome), " · ", otl_lab[m$otl]), levels = row_levels)
m$mode  <- factor(outc$mode[match(m$outcome, outc$outcome)], levels = names(mode_cols))
m$sig   <- factor(ifelse(m$p_value < .05, "p < .05", "not significant"), levels = names(sig_shapes))
m$panel <- model_lab[m$model]
fig1 <- ggplot(m, aes(estimate, row, colour = mode)) +
  geom_vline(xintercept = 0, colour = ink2, linewidth = .3) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high), height = 0, linewidth = .6) +
  geom_point(aes(shape = sig), size = 2.4, stroke = .8, fill = surface) +
  geom_text(data = m[m$p_value < .05, ], aes(x = ci_high, label = paste0(nz(estimate), "*")),
            hjust = -0.25, size = 3, colour = ink, show.legend = FALSE) +
  facet_wrap(~panel) +
  scale_colour_manual(values = mode_cols) + scale_shape_manual(values = sig_shapes, drop = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(.05, .18))) +
  labs(title = "Figure 1. SES × ICT moderation of the SES → achievement path",
       subtitle = "Standardized interaction path with 95% bootstrap CI, school level, primary runs (SES composite)",
       x = "SES × ICT → achievement", y = NULL,
       caption = "PISA 2012 US, 146 schools (Model 1) and 139 (Model 2). seminr PLS-SEM, two-stage interaction, 5,000 bootstrap samples.\nRows: outcome · OTL measure. Filled = p < .05 (t-test on the bootstrap SE, as in SmartPLS); bars = 95% percentile interval,\nwhich can touch zero in borderline cases. Labelled with the estimate.") +
  theme_viz + theme(panel.grid.major.y = element_line(colour = "#f1f0ed", linewidth = .25))
save(fig1, "fig1_moderation_all.png", 9, 7.5)

# ---- focal cell: the outcome x model with the most significant SES x ICT results -----------
sig <- m[m$p_value < .05, ]
if (nrow(sig)) {
  tab <- sort(table(paste(sig$outcome, sig$model)), decreasing = TRUE)
  fo <- strsplit(names(tab)[1], " ")[[1]]; f_out <- fo[1]; f_mod <- fo[2]
  f_otl <- if ("famconc" %in% sig$otl[sig$outcome == f_out & sig$model == f_mod]) "famconc" else
           sig$otl[sig$outcome == f_out & sig$model == f_mod][1]
} else { f_out <- "digital"; f_mod <- "M2"; f_otl <- "famconc" }
c_out <- outc$counterpart[outc$outcome == f_out]
otl_col <- c(famconc = "OTL", pt = "OTL_PT", expurem = "EXPUREM", exapplm = "EXAPPLM")

# ---- moderation statistics: effect size f² and Benjamini-Hochberg ------------------------
# f² = (R² with SES x ICT - R² without) / (1 - R² with), from a refit without the interaction.
# BH within each SES measure: across all 48 cells, and across the 12 FAMCONC cells (the spec's OTL).
mods <- est[est$id == "path_SESxICT_ACH", c("outcome", "otl", "model", "ses", "estimate", "se", "p_value", "ci_low", "ci_high")]
r2w  <- est[est$id == "r2_ACH", c("outcome", "otl", "model", "ses", "estimate")]; names(r2w)[5] <- "r2_with"
mods <- merge(mods, r2w, by = c("outcome", "otl", "model", "ses"))
mods$r2_without <- unname(mapply(function(o, t, m, s) {
  e <- suppressMessages(a2_estimate(m, outc$lv[outc$outcome == o], if (s == "escs") "ESCS" else "SES", otl_col[[t]], interaction = FALSE))
  e$rSquared["Rsq", "ACH"] }, mods$outcome, mods$otl, mods$model, mods$ses))
mods$f2 <- (mods$r2_with - mods$r2_without) / (1 - mods$r2_with)
mods$ci_excludes_0 <- mods$ci_low > 0 | mods$ci_high < 0
mods$p_bh_48 <- stats::ave(mods$p_value, mods$ses, FUN = function(p) stats::p.adjust(p, "BH"))
mods$p_bh_famconc_12 <- NA_real_
for (sv in unique(mods$ses)) { k <- mods$ses == sv & mods$otl == "famconc"; mods$p_bh_famconc_12[k] <- stats::p.adjust(mods$p_value[k], "BH") }
mods <- mods[order(mods$ses != "primary", mods$p_value), ]
mods_out <- mods; num_cols <- vapply(mods_out, is.numeric, logical(1))
mods_out[num_cols] <- lapply(mods_out[num_cols], function(x) signif(x, 4))
utils::write.csv(mods_out, "results/a2_seminr/moderation_stats.csv", row.names = FALSE)

# ---- Fig 2: simple slopes with bootstrap CIs ------------------------------------------------
z <- c(-1, 0, 1); zlab <- c("Low ICT (−1 SD)", "Mean ICT", "High ICT (+1 SD)")
ramp <- c("Low ICT (−1 SD)" = "#86b6ef", "Mean ICT" = "#2a78d6", "High ICT (+1 SD)" = "#104281")
slopes <- do.call(rbind, lapply(c(f_out, c_out), function(o) {
  f <- a2_fit_pls(f_mod, outc$lv[outc$outcome == o], "SES", otl_col[[f_otl]], nboot = nboot, return_boot = TRUE)
  bp <- f$boot$boot_paths; pc <- f$boot$path_coef
  do.call(rbind, lapply(seq_along(z), function(k) {
    draws <- bp["SES", "ACH", ] + bp["SES*ICT", "ACH", ] * z[k]
    data.frame(outcome = o, model = f_mod, otl = f_otl, ict_level = zlab[k], z = z[k],
               slope = pc["SES", "ACH"] + pc["SES*ICT", "ACH"] * z[k],
               ci_low = unname(stats::quantile(draws, .025)), ci_high = unname(stats::quantile(draws, .975)),
               b_ses = pc["SES", "ACH"], b_ict = pc["ICT", "ACH"], b_int = pc["SES*ICT", "ACH"],
               p_int = f$est$p_value[f$est$id == "path_SESxICT_ACH"])
  }))
}))
utils::write.csv(transform(slopes, slope = signif(slope, 6), ci_low = signif(ci_low, 6), ci_high = signif(ci_high, 6)),
                 "results/a2_seminr/simple_slopes.csv", row.names = FALSE)
ses_x <- seq(-2, 2, by = .1)
lines <- do.call(rbind, lapply(seq_len(nrow(slopes)), function(i) { s <- slopes[i, ]
  data.frame(outcome = s$outcome, ict_level = s$ict_level, ses = ses_x,
             ach = s$b_ses * ses_x + s$b_ict * s$z + s$b_int * ses_x * s$z) }))
panel_of <- function(o) { s <- slopes[slopes$outcome == o, ][1, ]
  sprintf("%s: SES × ICT = %s (p %s)", olab(o), nz(s$b_int), if (s$p_int < .001) "< .001" else paste("=", sub("^0", "", sprintf("%.3f", s$p_int)))) }
lines$panel  <- factor(vapply(lines$outcome, panel_of, ""), levels = c(panel_of(f_out), panel_of(c_out)))
slopes$panel <- factor(vapply(slopes$outcome, panel_of, ""), levels = levels(lines$panel))
lines$ict_level  <- factor(lines$ict_level, levels = zlab); slopes$ict_level <- factor(slopes$ict_level, levels = zlab)
ends <- merge(lines[lines$ses == 2, ], slopes[, c("outcome", "ict_level", "slope", "ci_low", "ci_high")], by = c("outcome", "ict_level"))
ends$lab <- sprintf("slope %s [%s, %s]", nz(ends$slope), nz(ends$ci_low), nz(ends$ci_high))
fig2 <- ggplot(lines, aes(ses, ach, colour = ict_level)) +
  geom_hline(yintercept = 0, colour = gridc, linewidth = .3) +
  geom_line(linewidth = .9) +
  geom_point(data = ends, size = 2.2) +
  geom_text(data = ends, aes(label = lab), hjust = -0.08, size = 2.9, colour = ink, show.legend = FALSE) +
  facet_wrap(~panel) +
  scale_colour_manual(values = ramp) +
  scale_x_continuous(breaks = -2:2, limits = c(-2, 3.6)) +
  labs(title = sprintf("Figure 2. Simple slopes: SES → achievement at three levels of %s",
                       if (f_mod == "M2") "school ICT resources" else "school ICT use"),
       subtitle = sprintf("%s, OTL = %s, SES composite. Direct effect only (OTL at its mean); standardized units.", model_lab[[f_mod]], otl_lab[[f_otl]]),
       x = "School SES (SD)", y = "Predicted achievement (SD)",
       caption = "Slope at ICT = z is b(SES) + b(SES × ICT)·z, as in SmartPLS simple-slope plots; 95% CIs from the 5,000 bootstrap draws.") +
  theme_viz + theme(panel.grid.major.y = element_line(colour = gridc, linewidth = .3))
save(fig2, "fig2_simple_slopes.png", 10, 4.6)

# ---- Fig 3: robustness of the focal moderation ----------------------------------------------
r <- est[est$id == "path_SESxICT_ACH" & est$outcome == f_out & est$model == f_mod, ]
r$row <- factor(otl_lab[r$otl], levels = rev(otl_lab))
r$ses_lab <- factor(ifelse(r$ses == "primary", "SES composite (primary)", "ESCS (sensitivity)"),
                    levels = c("SES composite (primary)", "ESCS (sensitivity)"))
r$sig <- factor(ifelse(r$p_value < .05, "p < .05", "not significant"), levels = names(sig_shapes))
dodge <- position_dodge(width = .5)
fig3 <- ggplot(r, aes(estimate, row, colour = ses_lab, group = ses_lab)) +
  geom_vline(xintercept = 0, colour = ink2, linewidth = .3) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high), height = 0, linewidth = .6, position = dodge) +
  geom_point(aes(shape = sig), size = 2.6, stroke = .8, fill = surface, position = dodge) +
  geom_text(aes(x = ci_high, label = sprintf("%s (p = %s)", nz(estimate), sub("^0", "", sprintf("%.3f", p_value)))),
            hjust = -0.1, size = 2.8, colour = ink, position = dodge, show.legend = FALSE) +
  scale_colour_manual(values = c("SES composite (primary)" = blue, "ESCS (sensitivity)" = orange)) +
  scale_shape_manual(values = sig_shapes, drop = FALSE) +
  scale_x_continuous(expand = expansion(mult = c(.05, .35))) +
  labs(title = sprintf("Figure 3. How robust is the %s moderation?", tolower(olab(f_out))),
       subtitle = sprintf("SES × ICT → %s, %s, by OTL measure and SES measure (95%% bootstrap CI)", tolower(olab(f_out)), model_lab[[f_mod]]),
       x = "SES × ICT → achievement", y = "OTL measure") +
  theme_viz
save(fig3, "fig3_moderation_robustness.png", 8, 4)

# ---- Fig 4: OTL -> achievement by OTL measure ----------------------------------------------
o <- est[est$id == "path_OTL_ACH" & est$ses == "primary", ]
o$row <- factor(olab(o$outcome), levels = rev(outc$label))
o$otl_f <- factor(otl_lab[o$otl], levels = otl_lab)
o$model_f <- factor(model_lab[o$model], levels = model_lab)
o$sig <- factor(ifelse(o$p_value < .05, "p < .05", "not significant"), levels = names(sig_shapes))
fig4 <- ggplot(o, aes(estimate, row, colour = model_f, group = model_f)) +
  geom_vline(xintercept = 0, colour = ink2, linewidth = .3) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high), height = 0, linewidth = .5, position = dodge) +
  geom_point(aes(shape = sig), size = 2.2, stroke = .8, fill = surface, position = dodge) +
  facet_wrap(~otl_f, nrow = 1) +
  scale_colour_manual(values = setNames(c(blue, orange), model_lab)) +
  scale_shape_manual(values = sig_shapes, drop = FALSE) +
  labs(title = "Figure 4. OTL → achievement depends on how OTL is measured",
       subtitle = "Standardized path with 95% bootstrap CI, primary runs. FAMCONC = familiarity with math concepts (spec); OTL_PT = ST73–76 problem types;\nEXPUREM / EXAPPLM = experience with pure / applied math tasks.",
       x = "OTL → achievement", y = NULL) +
  theme_viz
save(fig4, "fig4_otl_by_measure.png", 10, 4.2)

cat(sprintf("Focal moderation cell: %s, %s, OTL = %s; counterpart: %s. Figures in report/figures/\n",
            f_out, f_mod, f_otl, c_out))
