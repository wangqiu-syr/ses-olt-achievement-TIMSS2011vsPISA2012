"""Audit the US PISA 2012 student+school file against the OTL/SES/ICT plan.
Usage: python3 R/a2_00_audit_pisa2012.py data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav
Python (not R): a one-off exploratory audit, run before the R environment was set up.
Exploratory only: weighted with W_FSTUWT, PV-averaged correlations, no BRR SEs.
"""
import sys
import numpy as np
import pandas as pd
import pyreadstat

path = sys.argv[1]
OTL_L = ["ST73Q01", "ST74Q01", "ST75Q01", "ST76Q01"]
OTL_T = ["ST73Q02", "ST74Q02", "ST75Q02", "ST76Q02"]
SES = ["ST28Q01", "HISCED", "HISEI", "HOMEPOS"]
ICT = ["SC11Q02", "SC11Q03", "SC13Q01", "SC13Q02", "SC13Q03",
       "SC14Q07", "SC14Q08", "SC14Q09", "cSC40Q01"]
ICT_ALT = ["SC11Q01", "RATCMP15", "COMPWEB"]
OTL_ALT = ["FAMCON", "FAMCONC", "EXAPPLM", "EXPUREM"]
PV = [f"PV{i}MATH" for i in range(1, 6)]
cols = ["SCHOOLID", "W_FSTUWT", "ESCS"] + OTL_L + OTL_T + SES + ICT + ICT_ALT + OTL_ALT + PV
df, meta = pyreadstat.read_sav(path, usecols=cols)
w = df["W_FSTUWT"]


def wcorr(x, y, w):
    m = x.notna() & y.notna()
    x, y, w = x[m], y[m], w[m]
    mx, my = np.average(x, weights=w), np.average(y, weights=w)
    c = np.average((x - mx) * (y - my), weights=w)
    return c / np.sqrt(np.average((x - mx) ** 2, weights=w) * np.average((y - my) ** 2, weights=w)), m.sum()


def pv_corr(x):
    rs = [wcorr(x, df[p], w) for p in PV]
    return np.mean([r for r, _ in rs]), rs[0][1]


def alpha(items):
    d = items.dropna()
    k = d.shape[1]
    return k / (k - 1) * (1 - d.var().sum() / d.sum(axis=1).var()), len(d)


z = lambda s: (s - s.mean()) / s.std()
out = []
p = out.append
p(f"N students = {len(df)}, N schools = {df.SCHOOLID.nunique()}")
p(f"Students per school: median {df.groupby('SCHOOLID').size().median():.0f}, "
  f"min {df.groupby('SCHOOLID').size().min()}, max {df.groupby('SCHOOLID').size().max()}")

# Reverse-code OTL (1=Frequently..4=Never -> 4..1, higher = more OTL)
rev = lambda s: 5 - s
otl_l = df[OTL_L].apply(rev)
otl_t = df[OTL_T].apply(rev)
otl_all = pd.concat([otl_l, otl_t], axis=1)
df["OTL_lesson"] = otl_l.mean(axis=1, skipna=False)
df["OTL_test"] = otl_t.mean(axis=1, skipna=False)
df["OTL_8"] = otl_all.mean(axis=1, skipna=False)
p("\n## Missingness (non-missing N)")
for c in OTL_L + OTL_T + SES + ["ESCS"] + ICT + ICT_ALT + OTL_ALT:
    p(f"{c}: {df[c].notna().sum()}")
p(f"All 8 OTL items present: {otl_all.notna().all(axis=1).sum()}")
p(f"OTL (8) + 4 SES parts present: {(otl_all.notna().all(axis=1) & df[SES].notna().all(axis=1)).sum()}")

p("\n## Reliability (unweighted Cronbach alpha, listwise)")
for name, items in [("OTL lesson (4)", otl_l), ("OTL tests (4)", otl_t), ("OTL all (8)", otl_all)]:
    a, n = alpha(items)
    p(f"{name}: alpha={a:.2f} (n={n})")
sch = df.groupby("SCHOOLID")[ICT + ICT_ALT].first()
const = df.groupby("SCHOOLID")[ICT].nunique().max()
p(f"School vars constant within school: {bool((const <= 1).all())}")
ict_dir = sch[ICT].copy()
for c in ["SC14Q07", "SC14Q08", "SC14Q09"]:
    ict_dir[c] = 5 - ict_dir[c]          # higher = less shortage
ict_dir["cSC40Q01"] = 2 - ict_dir["cSC40Q01"]  # 1=yes,0=no
a, n = alpha(ict_dir.apply(z))
p(f"ICT 9 items as planned (school level, z-scored): alpha={a:.2f} (n schools={n})")
for name, its in [("SC13 internet use (3)", ["SC13Q01", "SC13Q02", "SC13Q03"]),
                  ("SC14 shortage (3)", ["SC14Q07", "SC14Q08", "SC14Q09"])]:
    a, n = alpha(sch[its])
    p(f"{name}: alpha={a:.2f} (n schools={n})")
p(f"School-level corr SC11Q02 (raw # computers) with SC11Q01 (# 10th graders): "
  f"{sch[['SC11Q02','SC11Q01']].corr().iloc[0,1]:.2f}")
p(f"School-level corr SC11Q02 with SC11Q03: {sch[['SC11Q02','SC11Q03']].corr().iloc[0,1]:.2f}")

p("\n## SES: planned composite vs PISA ESCS")
df["SES_plan"] = df[SES].apply(z).mean(axis=1, skipna=False)
r, n = wcorr(df["SES_plan"], df["ESCS"], w)
p(f"corr(SES_plan, ESCS) = {r:.2f} (n={n})")
r, n = wcorr(df["ST28Q01"], df["HOMEPOS"], w)
p(f"corr(books ST28Q01, HOMEPOS) = {r:.2f}  [HOMEPOS already includes books]")

p("\n## Weighted corr with math achievement (mean over 5 PVs)")
for c in ["SES_plan", "ESCS", "OTL_lesson", "OTL_test", "OTL_8"] + OTL_ALT:
    r, n = pv_corr(df[c])
    p(f"{c}: r={r:.2f} (n={n})")
for c in OTL_L + OTL_T:
    r, n = pv_corr(5 - df[c])
    p(f"{c} (reversed): r={r:.2f}")
for c in ["OTL_8", "FAMCONC"]:
    r, n = wcorr(df[c], df["ESCS"], w)
    p(f"corr({c}, ESCS) = {r:.2f}")
r, n = wcorr(df["OTL_8"], df["FAMCONC"], w)
p(f"corr(OTL_8, FAMCONC) = {r:.2f}")

p("\n## ICC of math achievement (PV1, unweighted one-way ANOVA estimate)")
g = df.groupby("SCHOOLID")["PV1MATH"]
k = g.size().mean()
msb = (g.size() * (g.mean() - df.PV1MATH.mean()) ** 2).sum() / (g.ngroups - 1)
msw = ((df.PV1MATH - g.transform("mean")) ** 2).sum() / (len(df) - g.ngroups)
p(f"ICC = {(msb - msw) / (msb + (k - 1) * msw):.2f}")

print("\n".join(out))
