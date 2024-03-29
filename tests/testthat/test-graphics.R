test_that("nlme_gastempt graphics creates a plot", {
  skip_on_cran()
  d = simulate_gastempt(seed = 4711)$data
  fit = nlme_gastempt(d)
  expect_is(fit, "nlme_gastempt")
  p = plot(fit)
  vdiffr::expect_doppelganger("nlme gastempt", p)
})
