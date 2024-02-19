
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ipctools: Utilities to Support Integrated Food Security Phase Classification (IPC) Data Analysis and Visualisation

<!-- badges: start -->

[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The [Integrated Food Security Phase Classification
(IPC)](https://www.ipcinfo.org/) is a widely used tool for classifying
and analyzing the severity and magnitude of food insecurity and
malnutrition situations in various countries and regions around the
world. It provides a common understanding of the food security situation
and enables decision-makers to take appropriate actions to mitigate and
respond to food crises. This package provides functions and utilities
that support IPC-related data analysis and visualisation.

## What does `ipctools` do?

Please note that `ipctools` is still highly experimental and is
undergoing a lot of development. Hence, any functionalities described
below have a high likelihood of changing interface or approach as we aim
for a stable working version.

Currently, the package provides utility functions that support the
processing, validation, and analysis of acute malnutrition datasets
based on IPC data standards and recommendations. Over time, it is aimed
that other similar data procesing, validation, and analysis steps
recommended by IPC on datasets for acute food insecurity and chronic
food insecurity can be incorporated.

In addition, it is planned to include a set of functions that would wrap
around the [IPC-CH
API](https://www.ipcinfo.org/ipc-country-analysis/api/) enabling
programmatic access to available resources from the IPC for researchers
and analysts who use R. For this purpose, a formal request for access to
the API has been submitted. Approval of this request will determine
whether this plan will come to fruition.

## Installation

`ipctools` is not yet on CRAN.

You can install the development version of `ipctools` from
[GitHub](https://github.com/nutriverse/ipctools) with:

``` r
if(!require(remotes)) install.packages("remotes")
remotes::install_github("nutriverse/ipctools")
```

then load `ipctools`

``` r
# load package
library(ipctools)
```

## Usage

### Performing checks on MUAC dataset

For nutrition survey datasets that include MUAC measurements, the IPC
recommends that the following tests be performed:

1.  **Age ratio test** - The ratio between those whose age is less than
    30 months to those who are 30 months and above.

2.  **Sex ratio test** - The male to female sex ratio test checks
    whether the ratio of the number of males to the number of females in
    a survey sample is similar to an expected ratio. It is usually
    assumed that there should be equal numbers of males and females in
    the survey sample.

3.  **Digit preference score** - Digit preference is the observation
    that the final number in a measurement occurs with a greater
    frequency than is expected by chance. This can occur because of
    rounding, the practice of increasing or decreasing the value in a
    measurement to the nearest whole or half unit, or because data are
    made up.

4.  **Standard deviation** - The stanard deviation of the MUAC
    measurements.

These checks can be performed using the `ipc_muac_check()` function as
follows:

``` r
ipc_muac_check(df = muac_data, muac_units = "cm", oedema_recode = c(1, 2))
#> $`Age Ratio`
#> $`Age Ratio`$ratio
#> [1] Inf
#> 
#> $`Age Ratio`$p
#> [1] 7.785732e-113
#> 
#> $`Age Ratio`$class
#> [1] Problematic
#> Levels: Problematic Poor Acceptable Excellent
#> 
#> 
#> $`Sex Ratio`
#> $`Sex Ratio`$ratio
#>         p 
#> 0.5057471 
#> 
#> $`Sex Ratio`$p
#> [1] 0.8479104
#> 
#> $`Sex Ratio`$class
#> [1] Excellent
#> Levels: Problematic Poor Acceptable Excellent
#> 
#> 
#> $`Digit Preference`
#> $`Digit Preference`$score
#> [1] 16.35
#> 
#> $`Digit Preference`$class
#> SMART DPS Class 
#>    "Acceptable" 
#> 
#> 
#> $`Standard Deviation`
#> $`Standard Deviation`$std_dev
#> [1] 12.45931
#> 
#> $`Standard Deviation`$class
#> [1] Excellent
#> Levels: Excellent Acceptable Poor Problematic
```

### Calculating acute malnutrition prevalence on a MUAC dataset

The IPC-recommended approach to calculating prevalence of acute
malnutrition based on MUAC is to perform a weighted analysis when either
the age ratio test or the sex ratio test is problematic. For example,
based on the MUAC check shown above, the example dataset `muac_data` has
some issues with its age ratio and sex ratio. To calculate acute
malnutrition prevalence from this dataset, a weighted analysis will have
to be implemented. This can be done using the
`ipc_calculate_prevalence()` function as follows:

``` r
ipc_muac_check(
  df = muac_data, muac_units = "cm", 
  oedema_recode = c(1, 2), 
  .summary = FALSE
) |>
  ipc_calculate_prevalence()
#> [1] 0.2179668
```

## Citation

If you find the `ipctools` package useful please cite using the
suggested citation provided by a call to the `citation()` function as
follows:

``` r
citation("ipctools")
#> To cite ipctools in publications use:
#> 
#>   Tomas Zaba and Ernest Guevarra (2024). ipctools: Utilities to Support
#>   Integrated Food Security Phase Classification (IPC) Data Analysis and
#>   Visualisation. R package version 0.0.9000. URL
#>   https://nutriverse.io/ipctools/
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {ipctools: Utilities to Support Integrated Food Security Phase Classification (IPC) Data Analysis and Visualisation},
#>     author = {{Tomas Zaba} and {Ernest Guevarra}},
#>     year = {2024},
#>     note = {R package version 0.0.9000},
#>     url = {https://nutriverse.io/ipctools/},
#>   }
```

## Community guidelines

Feedback, bug reports and feature requests are welcome; file issues or
seek support [here](https://github.com/nutriverse/ipctools/issues). If
you would like to contribute to the package, please see our
[contributing
guidelines](https://nutriverse.io/ipctools/CONTRIBUTING.html).

This project is released with a [Contributor Code of
Conduct](https://nutriverse.io/ipctools/CODE_OF_CONDUCT.html). By
participating in this project you agree to abide by its terms.
