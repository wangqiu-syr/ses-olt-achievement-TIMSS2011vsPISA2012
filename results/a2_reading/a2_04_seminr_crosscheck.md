# A2 cross-check: seminr vs. SmartPLS, reading

Built by `R/a2_04_seminr_crosscheck.R reading`. SmartPLS values come from `results/a2_reading/a2_pisa2012_estimates_*.csv` (read by `R/a2_02`).

## Verdict

- **Point estimates:** seminr reproduces SmartPLS to within 0.001 on every run. Largest gap across paths, effects, R², loadings, α, ρC and AVE: 0.0003.
- **Significance:** 24 of 24 paths reach the same verdict at p < .05 in both programs, and 16 of 16 total and indirect effects.
- **Bootstrap standard errors** differ by at most 0.0017. Different random resamples give small differences like this even within one program.
- The only visible point difference is the SES × ICT path (up to .0002): the two programs build the two-stage product term with slightly different numerics.

## Settings

- seminr 2.6.0, R 4.3.3. PLS-SEM with path weighting, mode A for ICT and READ, single items for SES (or ESCS) and OTL. SES × ICT by the two-stage approach. Up to 3,000 iterations, stop criterion 10⁻⁷; iterations used: M1_escs 3, M1_primary 3, M2_escs 3, M2_primary 3.
- Bootstrap: 5000 samples, seed 20261120, percentile 95% CIs, p from t with 4999 df. SmartPLS used 5,000 samples with its own fixed seed, so the resamples differ.
- Data: `data/derived/a2_smartpls_model{1,2}.csv`, the files SmartPLS read. Run time 49 s on 4 cores.

## Largest difference by estimate type (all four runs)

| Estimates | n | Max abs. difference | Max abs. difference in bootstrap SE |
|---|---|---|---|
| Path coefficients | 24 | 0.0003 | 0.0017 |
| Total effects | 8 | 0.0000 | 0.0021 |
| Indirect effects | 8 | 0.0000 | 0.0003 |
| R² | 8 | 0.0000 |  |
| Cronbach's α | 8 | 0.0000 |  |
| ρA | 8 | 0.0000 |  |
| ρC | 8 | 0.0000 |  |
| AVE | 8 | 0.0000 |  |
| ICT loadings | 12 | 0.0000 |  |
| HTMT | 24 | 0.0000 |  |
| Inner VIF | 24 | 0.0000 |  |
| Latent correlations | 24 | 0.0000 |  |

## Paths, side by side

Significance: \* p < .05, \*\* p < .01, \*\*\* p < .001.

| Run | Path | SmartPLS | seminr | Difference | SE SmartPLS | SE seminr | Same verdict at .05 |
|---|---|---|---|---|---|---|---|
| M1_primary | ICT_ACH | 0.092 | 0.092 | 0.0000 | 0.055 | 0.055 | yes |
| M1_primary | ICT_OTL | 0.125 | 0.125 | -0.0000 | 0.073 | 0.073 | yes |
| M1_primary | OTL_ACH | 0.420*** | 0.420*** | -0.0000 | 0.050 | 0.050 | yes |
| M1_primary | SES_ACH | 0.464*** | 0.464*** | 0.0000 | 0.059 | 0.057 | yes |
| M1_primary | SES_OTL | 0.518*** | 0.518*** | 0.0000 | 0.069 | 0.069 | yes |
| M1_primary | SESxICT_ACH | -0.076 | -0.076 | -0.0003 | 0.047 | 0.046 | yes |
| M1_escs | ICT_ACH | 0.091 | 0.091 | 0.0000 | 0.060 | 0.060 | yes |
| M1_escs | ICT_OTL | 0.137 | 0.137 | -0.0000 | 0.074 | 0.075 | yes |
| M1_escs | OTL_ACH | 0.456*** | 0.456*** | -0.0000 | 0.049 | 0.048 | yes |
| M1_escs | SES_ACH | 0.429*** | 0.429*** | 0.0000 | 0.060 | 0.059 | yes |
| M1_escs | SES_OTL | 0.475*** | 0.475*** | -0.0000 | 0.073 | 0.073 | yes |
| M1_escs | SESxICT_ACH | -0.058 | -0.059 | -0.0002 | 0.049 | 0.049 | yes |
| M2_primary | ICT_ACH | 0.017 | 0.017 | -0.0000 | 0.049 | 0.050 | yes |
| M2_primary | ICT_OTL | -0.001 | -0.001 | 0.0000 | 0.070 | 0.070 | yes |
| M2_primary | OTL_ACH | 0.411*** | 0.411*** | -0.0000 | 0.057 | 0.056 | yes |
| M2_primary | SES_ACH | 0.527*** | 0.527*** | 0.0000 | 0.056 | 0.056 | yes |
| M2_primary | SES_OTL | 0.614*** | 0.614*** | 0.0000 | 0.048 | 0.049 | yes |
| M2_primary | SESxICT_ACH | 0.080 | 0.080 | 0.0003 | 0.048 | 0.048 | yes |
| M2_escs | ICT_ACH | 0.030 | 0.030 | -0.0000 | 0.050 | 0.052 | yes |
| M2_escs | ICT_OTL | 0.019 | 0.019 | 0.0000 | 0.071 | 0.072 | yes |
| M2_escs | OTL_ACH | 0.460*** | 0.460*** | -0.0000 | 0.057 | 0.057 | yes |
| M2_escs | SES_ACH | 0.461*** | 0.461*** | 0.0000 | 0.062 | 0.062 | yes |
| M2_escs | SES_OTL | 0.579*** | 0.579*** | 0.0000 | 0.050 | 0.051 | yes |
| M2_escs | SESxICT_ACH | 0.028 | 0.028 | 0.0001 | 0.052 | 0.053 | yes |

## Total and indirect effects, side by side

| Run | Effect | SmartPLS | seminr | Difference | SE SmartPLS | SE seminr | Same verdict at .05 |
|---|---|---|---|---|---|---|---|
| M1_primary | tot_ICT_ACH | 0.145* | 0.145* | 0.0000 | 0.060 | 0.058 | yes |
| M1_primary | tot_SES_ACH | 0.681*** | 0.681*** | -0.0000 | 0.050 | 0.049 | yes |
| M1_primary | ind_ICT_OTL_ACH | 0.052 | 0.052 | -0.0000 | 0.032 | 0.032 | yes |
| M1_primary | ind_SES_OTL_ACH | 0.217*** | 0.217*** | -0.0000 | 0.036 | 0.036 | yes |
| M1_escs | tot_ICT_ACH | 0.154* | 0.154* | 0.0000 | 0.067 | 0.065 | yes |
| M1_escs | tot_SES_ACH | 0.646*** | 0.646*** | -0.0000 | 0.055 | 0.054 | yes |
| M1_escs | ind_ICT_OTL_ACH | 0.063 | 0.063 | -0.0000 | 0.036 | 0.036 | yes |
| M1_escs | ind_SES_OTL_ACH | 0.217*** | 0.217*** | -0.0000 | 0.038 | 0.038 | yes |
| M2_primary | tot_ICT_ACH | 0.017 | 0.017 | -0.0000 | 0.052 | 0.054 | yes |
| M2_primary | tot_SES_ACH | 0.780*** | 0.780*** | 0.0000 | 0.036 | 0.037 | yes |
| M2_primary | ind_ICT_OTL_ACH | -0.000 | -0.000 | 0.0000 | 0.029 | 0.029 | yes |
| M2_primary | ind_SES_OTL_ACH | 0.252*** | 0.252*** | -0.0000 | 0.035 | 0.035 | yes |
| M2_escs | tot_ICT_ACH | 0.038 | 0.038 | -0.0000 | 0.054 | 0.056 | yes |
| M2_escs | tot_SES_ACH | 0.727*** | 0.727*** | 0.0000 | 0.044 | 0.045 | yes |
| M2_escs | ind_ICT_OTL_ACH | 0.009 | 0.009 | -0.0000 | 0.033 | 0.033 | yes |
| M2_escs | ind_SES_OTL_ACH | 0.266*** | 0.266*** | -0.0000 | 0.035 | 0.035 | yes |
