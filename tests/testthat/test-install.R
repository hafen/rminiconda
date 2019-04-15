context("test-install")

test_that("Python 3 install works...", {
  install_miniconda()
})

test_that("Python 2 install works...", {
  install_miniconda(version = 2)
})
