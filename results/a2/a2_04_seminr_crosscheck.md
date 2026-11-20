# A2 cross-check: seminr vs. SmartPLS, math

Built by `R/a2_04_seminr_crosscheck.R`. SmartPLS values come from `results/a2/a2_pisa2012_estimates_*.csv` (read by `R/a2_02`).

## Verdict

- **Point estimates:** seminr reproduces SmartPLS to within 0.001 on every run. Largest gap across paths, effects, R², loadings, α, ρC and AVE: 0.0002.
- **Significance:** 24 of 24 paths reach the same verdict at p < .05 in both programs.
- **Bootstrap standard errors** differ by at most 0.0012. Different random resamples give small differences like this even within one program.
- The only visible point difference is the SES × ICT path (up to .0002): the two programs build the two-stage product term with slightly different numerics.

## Settings

- seminr 2.6.0, R 4.3.3. PLS-SEM with path weighting, mode A for ICT and MATH, single items for SES (or ESCS) and OTL. SES × ICT by the two-stage approach. Up to 3,000 iterations, stop criterion 10⁻⁷; iterations used: M1_escs 3, M1_primary 3, M2_escs 4, M2_primary 4.
- Bootstrap: 5000 samples, seed 20261120, percentile 95% CIs, p from t with 4999 df. SmartPLS used 5,000 samples with its own fixed seed, so the resamples differ.
- Data: `data/derived/a2_smartpls_model{1,2}.csv`, the files SmartPLS read. Run time 51 s on 4 cores.

## Largest difference by estimate type (all four runs)

| Estimates | n | Max abs. difference | Max abs. difference in bootstrap SE |
|---|---|---|---|
| Path coefficients | 24 | 0.0002 | 0.0012 |
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
| M1_primary | ICT_ACH | 0.035 | 0.035 | -0.0000 | 0.058 | 0.058 | yes |
| M1_primary | ICT_OTL | 0.125 | 0.125 | 0.0000 | 0.073 | 0.074 | yes |
| M1_primary | OTL_ACH | 0.370*** | 0.370*** | -0.0000 | 0.059 | 0.059 | yes |
| M1_primary | SES_ACH | 0.531*** | 0.531*** | 0.0000 | 0.064 | 0.063 | yes |
| M1_primary | SES_OTL | 0.518*** | 0.518*** | 0.0000 | 0.069 | 0.069 | yes |
| M1_primary | SESxICT_ACH | -0.053 | -0.053 | -0.0002 | 0.050 | 0.049 | yes |
| M1_escs | ICT_ACH | 0.038 | 0.038 | -0.0000 | 0.064 | 0.063 | yes |
| M1_escs | ICT_OTL | 0.137 | 0.137 | 0.0000 | 0.074 | 0.075 | yes |
| M1_escs | OTL_ACH | 0.418*** | 0.418*** | 0.0000 | 0.058 | 0.058 | yes |
| M1_escs | SES_ACH | 0.478*** | 0.478*** | 0.0000 | 0.069 | 0.069 | yes |
| M1_escs | SES_OTL | 0.476*** | 0.476*** | 0.0000 | 0.073 | 0.073 | yes |
| M1_escs | SESxICT_ACH | -0.049 | -0.049 | -0.0002 | 0.054 | 0.054 | yes |
| M2_primary | ICT_ACH | -0.019 | -0.019 | -0.0000 | 0.050 | 0.051 | yes |
| M2_primary | ICT_OTL | -0.002 | -0.002 | -0.0000 | 0.070 | 0.071 | yes |
| M2_primary | OTL_ACH | 0.377*** | 0.377*** | 0.0000 | 0.061 | 0.061 | yes |
| M2_primary | SES_ACH | 0.552*** | 0.552*** | -0.0000 | 0.060 | 0.060 | yes |
| M2_primary | SES_OTL | 0.615*** | 0.614*** | -0.0000 | 0.048 | 0.049 | yes |
| M2_primary | SESxICT_ACH | 0.028 | 0.028 | 0.0001 | 0.048 | 0.048 | yes |
| M2_escs | ICT_ACH | -0.004 | -0.004 | -0.0000 | 0.054 | 0.054 | yes |
| M2_escs | ICT_OTL | 0.018 | 0.018 | 0.0000 | 0.072 | 0.072 | yes |
| M2_escs | OTL_ACH | 0.435*** | 0.435*** | -0.0000 | 0.061 | 0.060 | yes |
| M2_escs | SES_ACH | 0.473*** | 0.473*** | -0.0000 | 0.066 | 0.066 | yes |
| M2_escs | SES_OTL | 0.580*** | 0.580*** | -0.0000 | 0.050 | 0.051 | yes |
| M2_escs | SESxICT_ACH | -0.021 | -0.021 | -0.0001 | 0.052 | 0.052 | yes |
