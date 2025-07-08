---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# meteo4Vilaine

<!-- badges: start -->
[![R-CMD-check](https://github.com/AnthonyDEBUR/meteo4Vilaine/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AnthonyDEBUR/meteo4Vilaine/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/AnthonyDEBUR/meteo4Vilaine/graph/badge.svg)](https://app.codecov.io/gh/AnthonyDEBUR/meteo4Vilaine)
<!-- badges: end -->

The goal of meteo4Vilaine is to ...

## Installation

You can install the development version of meteo4Vilaine from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("AnthonyDEBUR/meteo4Vilaine")
```

## Documentation

Full documentation website on: https://AnthonyDEBUR.github.io/meteo4Vilaine

## Example

This is a basic example which shows you how to solve a common problem:


``` r
library(meteo4Vilaine)
#> Error in library(meteo4Vilaine): aucun package nommé 'meteo4Vilaine' n'est trouvé
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so:


``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<div class="figure">
<img src="man/figures/README-pressure-1.png" alt="plot of chunk pressure" width="100%" />
<p class="caption">plot of chunk pressure</p>
</div>

In that case, don't forget to commit and push the resulting figure files, so they display on GitHub and CRAN.
