% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/httr2_suso_api_paradata.R
\name{suso_export_paradata}
\alias{suso_export_paradata}
\title{Export Survey Solutions paradata}
\usage{
suso_export_paradata(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  questID = NULL,
  version = NULL,
  from_date = NULL,
  from_time = "00:00:00",
  to_date = NULL,
  to_time = "23:59:59",
  workStatus = c("All", "SupervisorAssigned", "InterviewerAssigned",
    "RejectedBySupervisor", "Completed", "ApprovedBySupervisor",
    "RejectedByHeadquarters", "ApprovedByHeadquarters"),
  reloadTimeDiff = 1,
  inShinyApp = FALSE,
  multiCore = NULL,
  onlyActiveEvents = FALSE,
  asList = FALSE,
  allResponses = TRUE,
  gpsVarName = NA,
  verbose = FALSE,
  showProgress = FALSE
)
}
\arguments{
\item{server}{Survey Solutions server address}

\item{apiUser}{Survey Solutions API user}

\item{apiPass}{Survey Solutions API password}

\item{token}{If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored}

\item{workspace}{server workspace, if nothing provided, defaults to primary}

\item{questID}{\emph{QuestionnaireId} for which the paradata should be generated}

\item{version}{questionnnaire version}

\item{from_date}{if provided, only interviews started on this date or later will be included}

\item{from_time}{if provided, only interviews started at this time or later will be included}

\item{to_date}{if provided, only interviews started before or on this date will be included}

\item{to_time}{if provided, only interviews started before or at this time will be included}

\item{workStatus}{define which statuses the file should inlude (i.e. \emph{Restored,Created,SupervisorAssigned,InterviewerAssigned,
RejectedBySupervisor,ReadyForInterview,
SentToCapi,Restarted,Completed,ApprovedBySupervisor,
RejectedByHeadquarters,ApprovedByHeadquarters,Deleted}), if NULL all is exported}

\item{reloadTimeDiff}{time difference in hours between last generated file and now (will be ignored when \code{from_date} and
\code{to_date} is not \code{NULL})}

\item{inShinyApp}{if True, file interacts with shiny progress bar}

\item{multiCore}{if not NULL, an integer number specifying the number of cores to use}

\item{onlyActiveEvents}{if TRUE only active events are exported, decreases processing time and memory requirements}

\item{asList}{only used if \code{onlyActiveEvents = T}, if TRUE returns a list with a separate list element for each event, if FALSE returns
a single \emph{exportClass} data.table object. See details for more information.}

\item{allResponses}{if TRUE all responses will be extracted. Setting it to FALSE may decrease processing time and
memory requirements}

\item{gpsVarName}{provide GPS variable name. If not provided, identification is attempted by lookin for a variable containing gps in its name.}

\item{verbose}{if TRUE, shows messages about the operation carried out. Can be useful for longrunning operations.}

\item{showProgress}{also display the progress bars.}
}
\value{
a single exportClass data.table or a list of data.tables.
}
\description{
Exports Survey Solutions paradata, and returns either a single exportClass data.table,
or a list of data.tables.
}
\details{
\code{suso_export_paradata} returns a data.table. Calculates the response time
and separates multiple responses into individual columns. It also creates a variable
\emph{counter} which preserves the sequence of events.

The return value is a list with a separate list element for each event. If any of the variable
names contains \emph{gps} this function also attempts to identify (and extract) the geo-reference location. In case of multiple gps variables,
it identifies the first variable, with not all missing values. This in turn
facilitates the creation of paradata maps (see vignette on paradata). In addition it also returns all the variables and responses in separate columns and
as factors.
Exporting \emph{onlyActiveEvents} substantially decrease processing time. The events may be sufficient for most of the paradata analysis.

To further decrease the processing time, one could set \emph{allResponses} to FALSE. Doing so will still export all the data, however it will
not attempt to extract all responses and setting them to factors.
}
\examples{
\dontrun{
questlist<-suso_getQuestDetails()
# Get a single data.table with response timings,
# only active events,
# and responses are not expanded
para<-suso_export_paradata(questID = questlist$QuestionnaireId[1],
                           version = questlist$Version[1],
                           reloadTimeDiff = 0,
                           workStatus = "All",
                           asList = FALSE,
                           onlyActiveEvents = TRUE,
                           allResponses = F)

# Create a summary table
summary_data_table <- summaryTable(para)

# Display the summary table
summary_data_table
}

}
