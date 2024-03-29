% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stan_model_names.R
\name{stan_model_names}
\alias{stan_model_names}
\title{Names and descriptions of precompiled Stan models}
\usage{
stan_model_names(n_lines = 2, skip = 1, sep = "\\n")
}
\arguments{
\item{n_lines}{Number of comment lines to retrieve}

\item{skip}{Number of lines to skip from beginning of Stan Model file}

\item{sep}{separator for multiline strings}
}
\value{
A data frame with \code{model_name} and the first \code{n_lines}
comment lines in model as description
}
\description{
By default, line 2 and 3 of comments starting
with # or // in Stan file are returned
}
