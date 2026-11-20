# A2 cross-check: seminr vs. SmartPLS, science

Built by `R/a2_04_seminr_crosscheck.R science`. SmartPLS values come from `results/a2_science/a2_pisa2012_estimates_*.csv` (read by `R/a2_02`).

## Verdict

- **Point estimates:** seminr reproduces SmartPLS to within 0.001 on every run. Largest gap across paths, effects, R², loadings, α, ρC and AVE: 0.0003.
- **Significance:** 24 of 24 paths reach the same verdict at p < .05 in both programs, and 16 of 16 total and indirect effects.
- **Bootstrap standard errors** differ by at most 0.0015. Different random resamples give small differences like this even within one program.
- The only visible point difference is the SES × ICT path (up to .0002): the two programs build the two-stage product term with slightly different numerics.

## Settings

- seminr 2.6.0, R 4.3.3. PLS-SEM with path weighting, mode A for ICT and SCIE, single items for SES (or ESCS) and OTL. SES × ICT by the two-stage approach. Up to 3,000 iterations, stop criterion 10⁻⁷; iterations used: M1_escs 3, M1_primary 3, M2_escs 3, M2_primary 3.
- Bootstrap: 5000 samples, seed 20261120, percentile 95% CIs, p from t with 4999 df. SmartPLS used 5,000 samples with its own fixed seed, so the resamples differ.
- Data: `data/derived/a2_smartpls_model{1,2}.csv`, the files SmartPLS read. Run time 47 s on 4 cores.

## Largest difference by estimate type (all four runs)

| Estimates | n | Max abs. difference | Max abs. difference in bootstrap SE |
|---|---|---|---|
| Path coefficients | 24 | 0.0003 | 0.0015 |
| Total effects | 8 | 0.0000 | 0.0014 |
| Indirect effects | 8 | 0.0000 | 0.0006 |
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
| M1_primary | ICT_ACH | 0.027 | 0.027 | 0.0000 | 0.059 | 0.058 | yes |
| M1_primary | ICT_OTL | 0.125 | 0.125 | -0.0000 | 0.073 | 0.074 | yes |
| M1_primary | OTL_ACH | 0.344*** | 0.344*** | -0.0000 | 0.062 | 0.061 | yes |
| M1_primary | SES_ACH | 0.545*** | 0.545*** | 0.0000 | 0.067 | 0.065 | yes |
| M1_primary | SES_OTL | 0.519*** | 0.519*** | 0.0000 | 0.069 | 0.069 | yes |
| M1_primary | SESxICT_ACH | -0.071 | -0.071 | -0.0003 | 0.049 | 0.048 | yes |
| M1_escs | ICT_ACH | 0.031 | 0.031 | 0.0000 | 0.065 | 0.064 | yes |
| M1_escs | ICT_OTL | 0.136 | 0.136 | -0.0000 | 0.074 | 0.075 | yes |
| M1_escs | OTL_ACH | 0.397*** | 0.397*** | -0.0000 | 0.060 | 0.059 | yes |
| M1_escs | SES_ACH | 0.483*** | 0.483*** | 0.0000 | 0.071 | 0.070 | yes |
| M1_escs | SES_OTL | 0.476*** | 0.476*** | 0.0000 | 0.073 | 0.073 | yes |
| M1_escs | SESxICT_ACH | -0.057 | -0.058 | -0.0002 | 0.055 | 0.055 | yes |
| M2_primary | ICT_ACH | -0.017 | -0.017 | -0.0000 | 0.052 | 0.051 | yes |
| M2_primary | ICT_OTL | -0.001 | -0.001 | 0.0000 | 0.070 | 0.071 | yes |
| M2_primary | OTL_ACH | 0.329*** | 0.329*** | 0.0000 | 0.067 | 0.066 | yes |
| M2_primary | SES_ACH | 0.593*** | 0.593*** | 0.0000 | 0.066 | 0.065 | yes |
| M2_primary | SES_OTL | 0.614*** | 0.614*** | 0.0000 | 0.048 | 0.050 | yes |
| M2_primary | SESxICT_ACH | 0.054 | 0.054 | 0.0002 | 0.048 | 0.048 | yes |
| M2_escs | ICT_ACH | -0.001 | -0.001 | 0.0000 | 0.055 | 0.054 | yes |
| M2_escs | ICT_OTL | 0.019 | 0.019 | -0.0000 | 0.072 | 0.072 | yes |
| M2_escs | OTL_ACH | 0.395*** | 0.395*** | 0.0000 | 0.065 | 0.064 | yes |
| M2_escs | SES_ACH | 0.498*** | 0.498*** | -0.0000 | 0.070 | 0.069 | yes |
| M2_escs | SES_OTL | 0.579*** | 0.579*** | 0.0000 | 0.050 | 0.051 | yes |
| M2_escs | SESxICT_ACH | -0.009 | -0.009 | -0.0000 | 0.051 | 0.052 | yes |

## Total and indirect effects, side by side

| Run | Effect | SmartPLS | seminr | Difference | SE SmartPLS | SE seminr | Same verdict at .05 |
|---|---|---|---|---|---|---|---|
| M1_primary | tot_ICT_ACH | 0.070 | 0.070 | 0.0000 | 0.060 | 0.059 | yes |
| M1_primary | tot_SES_ACH | 0.724*** | 0.724*** | -0.0000 | 0.049 | 0.048 | yes |
| M1_primary | ind_ICT_OTL_ACH | 0.043 | 0.043 | -0.0000 | 0.026 | 0.026 | yes |
| M1_primary | ind_SES_OTL_ACH | 0.178*** | 0.178*** | -0.0000 | 0.036 | 0.036 | yes |
| M1_escs | tot_ICT_ACH | 0.085 | 0.085 | 0.0000 | 0.067 | 0.066 | yes |
| M1_escs | tot_SES_ACH | 0.672*** | 0.672*** | 0.0000 | 0.057 | 0.057 | yes |
| M1_escs | ind_ICT_OTL_ACH | 0.054 | 0.054 | -0.0000 | 0.030 | 0.031 | yes |
| M1_escs | ind_SES_OTL_ACH | 0.189*** | 0.189*** | -0.0000 | 0.037 | 0.037 | yes |
| M2_primary | tot_ICT_ACH | -0.017 | -0.017 | -0.0000 | 0.053 | 0.052 | yes |
| M2_primary | tot_SES_ACH | 0.795*** | 0.795*** | 0.0000 | 0.039 | 0.039 | yes |
| M2_primary | ind_ICT_OTL_ACH | -0.000 | -0.000 | 0.0000 | 0.024 | 0.024 | yes |
| M2_primary | ind_SES_OTL_ACH | 0.202*** | 0.202*** | -0.0000 | 0.038 | 0.038 | yes |
| M2_escs | tot_ICT_ACH | 0.007 | 0.007 | 0.0000 | 0.056 | 0.056 | yes |
| M2_escs | tot_SES_ACH | 0.727*** | 0.727*** | -0.0000 | 0.046 | 0.047 | yes |
| M2_escs | ind_ICT_OTL_ACH | 0.008 | 0.008 | 0.0000 | 0.029 | 0.029 | yes |
| M2_escs | ind_SES_OTL_ACH | 0.229*** | 0.229*** | 0.0000 | 0.037 | 0.036 | yes |
