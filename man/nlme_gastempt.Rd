% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fitnlme.R
\name{nlme_gastempt}
\alias{nlme_gastempt}
\title{Simplified population fit of gastric emptying data}
\usage{
nlme_gastempt(d, pnlsTol = 0.001, model = linexp, variant = 1)
}
\arguments{
\item{d}{A data frame with columns
\itemize{
  \item \code{record} Record descriptor as grouping variable, e.g. patient ID
  \item \code{minute} Time after meal or start of recording.
  \item \code{vol} Volume of meal or stomach
 }}

\item{pnlsTol}{The value of pnlsTol at the initial iteration.
See \code{\link[nlme]{nlmeControl}}  When the model does not converge,
\code{pnlsTol} is multiplied by 5 and the iteration repeated until
convergence or \code{pnlsTol >= 0.5}.
The effective value of  \code{pnlsTol} is returned in a separate list item.
When it is known that a data set converges badly,
it is recommended to set the initial \code{pnlsTol} to a higher value,
but below 0.5, for faster convergence.}

\item{model}{\code{linexp} (default) or \code{powexp}}

\item{variant}{For both models, there are 3 variants
\itemize{
  \item \code{variant = 1} The most generic version with independent estimates
  of all three parameters per record
  (\code{random = v0 + tempt + kappa ~ 1 | record}). The most likely to fail
  for degenerate cases. If this variant converges, use it.
  \item \code{variant = 2 } Diagonal random effects
  (\code{random = pdDiag(v0 + tempt + kappa) ~ 1; groups =  ~record }).
  Better convergence in critical cases. Note:  I never found out why I have
  to use the \code{groups} parameter instead of the \code{|};
  see also p. 380 of Pinheiro/Bates.
  \item \code{variant = 3} Since parameters \code{kappa} and
  \code{beta} respectively are the most difficult to estimate, these are
  fixed in this variant (\code{random = v0 + tempt ~ 1}).
  This variant converges in all reasonable cases, but the estimates
  of \code{kappa} and \code{beta} cannot be use for secondary
  between-group analysis. If you are only interested in \code{t50},
  you can use this safe version.
  }}
}
\value{
A list of class nlme_gastempt with elements
\code{coef, summary, plot, pnlsTol, message}
\itemize{
  \item \code{coef} is a data frame with columns:
    \itemize{
      \item \code{record} Record descriptor, e.g. patient ID
      \item \code{v0} Initial volume at t=0
      \item \code{tempt} Emptying time constant
      \item \code{kappa} Parameter \code{kappa} for
            \code{model = linexp}
      \item \code{beta} Parameter \code{beta} for \code{model = powexp}
      \item \code{t50} Half-time of emptying
      \item \code{slope_t50} Slope in t50; typically in units of ml/minute
 }
 On error, coef is NULL
  \item \code{nlme_result} Result of the nlme fit; can be used for addition
     processing, e.g. to plot residuals or via \code{summary} to extract AIC.
     On error, nlme_result is NULL.
  \item \code{plot} A ggplot graph of data and prediction. Plot of raw data is
     returned even when convergence was not achieved.
  \item \code{pnlsTol} Effective value of pnlsTo after convergence or failure.
  \item \code{message} String "Ok" on success, and the error message of
     \code{nlme} on failure.
 }
}
\description{
Compute coefficients v0, tempt and kappa of a mixed model fit to a linexp
function with one grouping variable
}
\examples{
suppressWarnings(RNGversion("3.5.0"))
set.seed(4711)
d = simulate_gastempt(n_record = 10, kappa_mean = 0.9, kappa_std = 0.3,
                      model = linexp)$data
fit_d = nlme_gastempt(d)
# fit_d$coef # direct access
coef(fit_d) # better use accessor function
coef(fit_d, signif = 3) # Can also set number of digits
# Avoid ugly ggplot shading (not really needed...)
library(ggplot2)
theme_set(theme_bw() + theme(panel.spacing = grid::unit(0,"lines")))
# fit_d$plot  # direct access is possible
plot(fit_d) # better use accessor function
}
