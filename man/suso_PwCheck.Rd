% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr2_suso_api_credentials.R
\name{suso_PwCheck}
\alias{suso_PwCheck}
\title{Utility function to check if credentials are correct}
\usage{
suso_PwCheck(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL
)
}
\arguments{
\item{server}{Survey Solutions Server}

\item{apiUser}{API user}

\item{apiPass}{API password}

\item{workspace}{server workspace Name, if nothing provided, defaults to primary}

\item{token}{If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored}
}
\value{
200 code if correct, 400 if incorrect.
}
\description{
This function returns a 200 status code if credentials are correct and a 400 code otherwise.
}
\details{
If the app runs interactively, status is printed to the console, if it runs in a shiny app, a status
notification will be shown, if option \option{suso.useshiny} is \code{TRUE}.
}
