% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr2_suso_api_user.R
\name{suso_getINT_info}
\alias{suso_getINT_info}
\title{Survey Solutions API call for info on interviewers}
\usage{
suso_getINT_info(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  int_id = NULL,
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  log = FALSE,
  startDate = NULL,
  endDate = NULL
)
}
\arguments{
\item{server}{Survey Solutions server address}

\item{apiUser}{Survey Solutions API user}

\item{apiPass}{Survey Solutions API password}

\item{int_id}{interviewer id}

\item{workspace}{If workspace name is provide requests are made regarding this specific workspace, if
no workspace is provided defaults to primary workspace.}

\item{token}{If Survey Solutions server token is provided \emph{usr} and \emph{pass} will be ignored}

\item{log}{If TRUE, then the audit log is returned}

\item{startDate}{Start data for the period of interest, date must be provided as character in the format:
YYYY-MM-DD, and will start at 00:00.00 server time of the specified day}

\item{endDate}{End date for the period of interest, date must be provided ascharacter in the format:
YYYY-MM-DD, and will end at 23:59:59 server time of the specified day. If not end date is provided, the current
date will be used}
}
\description{
Get details of a single interviewer or retrieve the action log
}
\examples{
\dontrun{
suso_getINT_info(
          workspace = "myworkspace",
          int_id = "xxxx-xxxx-xxxx-xxx"
          )
}

}
