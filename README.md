# rminiconda

[![Travis build status](https://travis-ci.org/hafen/rminiconda.svg?branch=master)](https://travis-ci.org/hafen/rminiconda)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/hafen/rminiconda?branch=master&svg=true)](https://ci.appveyor.com/project/hafen/rminiconda)

This R package provides utilities for installing an isolated "miniconda" Python environment. It is intended mainly for use with the [reticulate](https://rstudio.github.io/reticulate/) package, with the particular use case of allowing R users to use R packages that wrap Python libraries without having to worry about maintaining a Python environment.

## Installation

You can install rminiconda from github with:

``` r
devtools::install_github("hafen/rminiconda")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
rminiconda::install_miniconda()
```
