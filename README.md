
<!-- README.md is generated from README.Rmd. Please edit that file -->

# decompositionLE

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/decompositionLE)](https://CRAN.R-project.org/package=decompositionLE)
[![Codecov test
coverage](https://codecov.io/gh/herts-phei/decompositionLE/graph/badge.svg)](https://app.codecov.io/gh/herts-phei/decompositionLE)
[![R-CMD-check](https://github.com/herts-phei/decompositionLE/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/herts-phei/decompositionLE/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of **decompositionLE** is to provide an easy to use
implementation of life expectancy decomposition formulas for age bands,
derived from *Ponnapalli, K. (2005). A comparison of different methods
for decomposition of changes in expectation of life at birth and
differentials in life expectancy at birth. Demographic Research, 12,
pp.141–172. doi: <https://doi.org/10.4054/demres.2005.12.7>.* In
addition, there is a decomposition function for disease cause breakdown,
as well as some useful helper plot functions.

## Installation

You can install the development version of decompositionLE from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("herts-phei/decompositionLE")
```

## Example

The package contains a built-in dataset of life table values for US
women born in 1935 and 1995, `us_females`, sourced from *Ponnapalli, K.
(2005).*.

``` r
us_females
#>    Age     nm1x     l1x   e1x     nm2x     l2x   e2x
#> 1    0 0.047139 1.00000 63.32 0.006830 1.00000 79.00
#> 2    1 0.004157 0.95458 65.32 0.000358 0.99321 78.54
#> 3    5 0.001525 0.93887 62.39 0.000167 0.99179 74.65
#> 4   10 0.001208 0.93174 57.85 0.000196 0.99096 69.71
#> 5   15 0.002022 0.92613 53.19 0.000459 0.98999 64.78
#> 6   20 0.002944 0.91681 48.70 0.000503 0.98772 59.92
#> 7   25 0.003562 0.90341 44.38 0.000647 0.98524 55.06
#> 8   30 0.003980 0.88746 40.14 0.000892 0.98206 50.23
#> 9   35 0.005003 0.86997 35.89 0.001266 0.97769 45.45
#> 10  40 0.005927 0.84847 31.74 0.001765 0.97152 40.72
#> 11  45 0.008310 0.82368 27.61 0.002612 0.96298 36.06
#> 12  50 0.011638 0.79012 23.67 0.004171 0.95048 31.49
#> 13  55 0.016309 0.74539 19.94 0.006575 0.93085 27.10
#> 14  60 0.024373 0.68688 16.41 0.010387 0.90071 22.92
#> 15  65 0.035823 0.60779 13.21 0.016349 0.85504 19.00
#> 16  70 0.055769 0.50757 10.31 0.024504 0.78775 15.40
#> 17  75 0.092454 0.38276  7.82 0.038841 0.69655 12.07
#> 18  80 0.130808 0.23930  6.03 0.063900 0.57275  9.12
#> 19 85+ 0.222482 0.12281  4.49 0.151106 0.41424  6.62
```

The package also contains a built-in dataset of age and cause
decomposition of difference in Life Expectancies at birth, for India and
China, males, 1990, `india_china_males_1990`, sourced from *Murray,
C.J.L. and Lopez, A.D. (1996)*.

``` r
india_china_males_1990
#>   Age India_nmx India_CD India_NCD India_Injuries China_nmx China_CD China_NCD
#> 1   0    0.0267    0.882     0.073          0.046    0.0084    0.677     0.174
#> 2   5    0.0025    0.504     0.188          0.309    0.0009    0.174     0.337
#> 3  15    0.0021    0.382     0.223          0.394    0.0015    0.068     0.380
#> 4  30    0.0043    0.429     0.315          0.257    0.0028    0.101     0.573
#> 5  45    0.0139    0.304     0.592          0.104    0.0102    0.095     0.796
#> 6  60    0.0388    0.248     0.722          0.030    0.0342    0.070     0.879
#> 7 70+    0.0929    0.247     0.728          0.025    0.1003    0.084     0.877
#>   China_Injuries  nDx
#> 1          0.149  5.6
#> 2          0.488  0.8
#> 3          0.552  0.3
#> 4          0.326  0.6
#> 5          0.109  0.8
#> 6          0.051  0.3
#> 7          0.039 -0.3
```
