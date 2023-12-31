% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr2_suso_api_user.R
\name{suso_getUSR}
\alias{suso_getUSR}
\title{Survey Solutions API call for info on any user}
\usage{
suso_getUSR(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  user_id = NULL,
  user_name = NULL,
  user_email = NULL,
  workspace = suso_get_api_key("workspace"),
  token = NULL
)
}
\arguments{
\item{server}{Survey Solutions server address}

\item{apiUser}{Survey Solutions API user}

\item{apiPass}{Survey Solutions API password}

\item{user_id}{user id}

\item{user_name}{user name}

\item{user_email}{user email}

\item{workspace}{If workspace name is provide requests are made regarding this specific workspace, if
no workspace is provided defaults to primary workspace.}

\item{token}{If Survey Solutions server token is provided \emph{usr} and \emph{pass} will be ignored}
}
\description{
Get any user's info, by either providing the user id, email, or the user name
}
\examples{
\dontrun{
suso_getUSR(
          workspace = "myworkspace",
          uid = "xxxx-xxxx-xxxx-xxx"
          )
}

}
