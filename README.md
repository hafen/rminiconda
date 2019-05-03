# rminiconda

[![Travis build status](https://travis-ci.org/hafen/rminiconda.svg?branch=master)](https://travis-ci.org/hafen/rminiconda)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/hafen/rminiconda?branch=master&svg=true)](https://ci.appveyor.com/project/hafen/rminiconda)

This R package provides utilities for installing isolated "miniconda" Python environments.

It is intended mainly for use with the [reticulate](https://rstudio.github.io/reticulate/) package, with the particular use case of enabling R package developers to write R packages that wrap Python libraries without their users having to worry about installing or configuring anything outside of R.

## Motivation

The amazing [reticulate](https://rstudio.github.io/reticulate/) package opens up access to many data analysis methods implemented in Python without needing to leave R. One major hurdle, however, is that for users to use reticulate, they must have a properly installed and configured Python environment with the right Python packages installed, etc.

While reticulate provides some great utilities for finding Python, installing Python packages, and maintaining Python environments, it is inevitable that at some point a user will need to do something manually in their system outside of R to get their Python environment installed or configured properly (I have encountered this countless times...). This expectation is fine for many users, but for R package developers who are wrapping Python packages but want a completely seamless experience for their users, this is less than ideal.

The rminiconda package provides a simple R function that installs [miniconda](https://docs.conda.io/en/latest/miniconda.html) in an isolated, "namespaced" location that you can fully customize for your particular use case. It also provides utilities for making this installation and configuration part of an R package setup. The miniconda Python installations provided by rminiconda do not interfere with any other Python installation on your system. It works on Linux, MacOS, and Windows.

## Install

You can install rminiconda from github with:

``` r
# install.packages("remotes") # if not installed
remotes::install_github("hafen/rminiconda")
```

## Standalone Usage

If you want to install an isolated miniconda for your own uses, you can simply call `install_miniconda()`.

``` r
rminiconda::install_miniconda(name = "my_python")
```

This will place an isolated miniconda installation in a directory called `"my_python` in a base directory that houses all miniconda installations installed through rminiconda. The base directory is determined based on the following rules:

- If a system environment variable, `R_MINICONDA_PATH` exists, this will be used as the base installation directory.
- Otherwise, if the rminiconda package directory is user-writable, this will be used as the base installation directory.
- Otherwise, the directory `~/rminiconda` will be used as the base installation directory.

You can specify for this installation to be used with reticulate with the following:

```r
py <- rminiconda::find_miniconda_python("my_python")
reticulate::use_python(py, required = TRUE)
```

You can install either Python version 2 or 3 with the `version` argument. Also, you can maintain as many miniconda installations as you would like by using different names for each one.

```r
rminiconda::install_miniconda(version = 2, name = "my_python2")
```

Note that currently rminiconda only installs the latest miniconda for Python 2 and Python 3. Installing specific Python versions may be supported in the future.

## Usage in an R Package

If you are writing an R package that depends on a Python library but you don't want your users to worry about any aspect of Python installation and configuration, you can use rminiconda to configure your users's environment for them.

Suppose, for example, that you want to wrap functionality in the Python [shap](https://github.com/slundberg/shap) package in your own R package (Note that this has already been done with [shapper](https://github.com/ModelOriented/shapper) - this is just an example). Suppose you have named this package "shapr". A recipe for using rminiconda as part of your package might look something like this:

```r
#' @import rminiconda
.onLoad <- function(libname, pkgname) {
  # Undesirable side-effects but if not unset, can lead to config issues
  Sys.setenv(PYTHONHOME = "")
  Sys.setenv(PYTHONPATH = "")
  is_configured()
}

# Check to see if the shapr Python environment has been configured
is_configured <- function() {
  # Should also check that the required packages are installed
  if (!rminiconda::is_miniconda_installed("shapr")) {
    message("It appears that shapr has not been configured...")
    message("Run 'shapr_configure()' for a one-time setup.")
    return (FALSE)
  } else {
    py <- rminiconda::find_miniconda_python("shapr")
    reticulate::use_python(py, required = TRUE)
    return (TRUE)
  }
}

#' One-time configuration of environment for shapr
#'
#' @details This installs an isolated Python distribution along with required dependencies so that the shapr R package can seamlessly wrap the shap Python package.
#' @export
shapr_configure <- function() {
  # Install isolated miniconda
  if (!rminiconda::is_miniconda_installed("shapr"))
    rminiconda::install_miniconda(version = 3, name = "shapr")
  # Install python packages
  py <- rminiconda::find_miniconda_python("shapr")
  rminiconda::rminiconda_pip_install("shap", "shapr")
  reticulate::use_python(py, required = TRUE)
}
```

You might optionally want to check to see if the user already has a non-rminiconda Python environment properly configured and use that in that case.

You might have a collection of R packages that wrap Python libraries, for example, maybe relating to different parts of an ML pipeline, and "shapr" is just one of them. In that case you could use a common Python installation namespace across all packages, such as "ml-pipeline", and use that across all of your package configurations.

## Development Status

I'm interested to see the general level of interest in the existence of a package such as this and welcome feedback and discussion with those who surely know more than I do in this area to help it get a "production-ready" stamp of approval. Please use [Github issues](https://github.com/hafen/rminiconda/issues) to engage.
