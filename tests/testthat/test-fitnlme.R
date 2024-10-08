# only for debugging
if (FALSE) {
  library(testthat)
  library(ggplot2)
  library(assertthat)
  library(nlme)
  library(dplyr)
}

test_that("nlme_gastempt returns a valid structure", {
  skip_on_cran()
  d = simulate_gastempt(seed = 4712)$data
  fit = nlme_gastempt(d)
  expect_s3_class(fit, "nlme_gastempt")
  expect_equal(fit$message, "Ok")
  expect_equal(names(fit), c("coef", "nlme_result", "plot", "pnlsTol", "message"))
  expect_s3_class(plot(fit), "ggplot")
  expect_s3_class(coef(fit), "data.frame")
  expect_equal(as.numeric(coef(fit, signif = 1)[1, 2]), 400)
})

test_that("nlme_gastempt can handle noisy and missing data", {
  # https://www.stats.ox.ac.uk/pub/bdr/M1mac/gastempt.out
  d = simulate_gastempt(kappa_mean = 1, noise = 40, student_t_df = 3,
                        seed = 11)$data
  fit = nlme_gastempt(d)
  expect_equal(fit$message, "Ok")
  # many missing
  # fails on aarch64, but skip_on_cran or skip_on_os("mac") does not help
  skip("Skipped because it fails on aarch64")
  d = simulate_gastempt(kappa_mean = 1, noise = 30, missing = 0.40,
                        student_t_df = 5, seed = 12)$data
  fit = nlme_gastempt(d)
  expect_equal(fit$message, "Ok")
})



test_that("nlme_gastempt with special data fails", {
  # This fails
  d = simulate_gastempt(seed = 1706)$data
  fit = nlme_gastempt(d, model = linexp)
  expect_equal(fit$pnlsTol, 0.625)

  # Try pdDiag works
  fit = nlme_gastempt(d, variant = 2)
  expect_equal(fit$pnlsTol, 0.001)

  # Try constant beta
  fit = nlme_gastempt(d, variant = 3)
  expect_equal(fit$pnlsTol, 0.001)
})


search_pnls_tol = function(model = linexp, nlme_model = linexp,
                          variant = 1) {
  # Only used manually to find interesting start values for test design
  suppressWarnings(RNGversion("3.5.0"))
  set.seed(4711)
  while (TRUE) {
    r = sample.int(10000, 1)
    d = simulate_gastempt(model = model, seed = r)$data
    fit = nlme_gastempt(d, model = nlme_model, variant = variant)
    cat(r, " ", fit$pnlsTol, fit$nl$numIter, "\n")
  }
}


test_that("fit of powexp data to powexp curve gives valid coefficients", {
  d = simulate_gastempt(model = powexp, seed = 4711)$data
  expect_match(comment(d), "beta")
  fit = nlme_gastempt(d, model = powexp)
  expect_equal(fit$pnlsTol, 0.001)
  expect_s3_class(fit, "nlme_gastempt")
  expect_equal(fit$message, "Ok")
  expect_equal(names(fit), c("coef", "nlme_result", "plot", "pnlsTol", "message"))
  expect_s3_class(plot(fit), "ggplot")
  expect_s3_class(coef(fit), "data.frame")
  fit = nlme_gastempt(d, model = powexp, variant = 2)
  expect_equal(fit$pnlsTol, 0.001)
  fit = nlme_gastempt(d, model = powexp, variant = 3)
  expect_equal(fit$pnlsTol, 0.001)
})


test_that("fit of default powexp data to linexp curve fails often", {
  skip_on_cran() # Avoid problems with ATLAS
  d = simulate_gastempt(model = powexp, seed = 9344)$data
  fit = nlme_gastempt(d, model = linexp)
  expect_match(fit$message, "pnlsTol")
  # variant 2 fails
  fit = nlme_gastempt(d, model = linexp, variant = 2)
  expect_match(fit$message, "pnlsTol")
  # variant 3 fails
  fit = nlme_gastempt(d, model = linexp, variant = 3)
  expect_match(fit$message, "pnlsTol")
})

test_that("fit of powexp data with beta=2 to linexp curve converges", {
  d = simulate_gastempt(beta_mean = 2, model = powexp, seed = 4711)$data
  fit = nlme_gastempt(d, model = linexp)
  expect_equal(fit$pnlsTol, 0.001)
  expect_equal(fit$message, "Ok")
  fit = nlme_gastempt(d, model = linexp)
})
