% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr2_suso_api_credentials.R
\name{suso_set_key}
\alias{suso_set_key}
\title{Set all credentials at once}
\usage{
suso_set_key(
  suso_server = "",
  suso_user = "",
  suso_password = "",
  workspace = NULL,
  suso_token = ""
)
}
\arguments{
\item{suso_server}{Survey Solutions server address}

\item{suso_user}{Survey Solutions API user}

\item{suso_password}{Survey Solutions API password}

\item{workspace}{server workspace Name, if nothing provided, defaults to primary}

\item{suso_token}{If Survey Solutions server token is provided \emph{suso_user} and \emph{suso_password} will be ignored}
}
\description{
Sets API credentials so it's available for all API calls. See details
}
\details{
Use \code{suso_set_key} to make API keys available for all the \code{suso_}
functions, so you don't need to specify the credentials parameter within those
functions. The server address can be provided with or without https:\\ suffix,
nevertheless if it is missing, then the suffix will be added. For testing purposes
it also allows for http connections, however for publicly accessible servers
we do not recommend unencrypted connections.

In case \emph{suso_token} is provided, only token authentication will be attempted. For details on token authentication
in Survey Solutions please see \url{https://docs.mysurvey.solutions/headquarters/accounts/token-based-authentication/}.
}
