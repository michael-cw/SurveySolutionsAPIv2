% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_export_class.R
\name{summaryTable}
\alias{summaryTable}
\alias{summaryTable.exportClass}
\alias{summaryTable.paradata}
\title{S3 method to create a summary table of numeric variables for an exportClass object}
\usage{
summaryTable(x, ...)

\method{summaryTable}{exportClass}(x, ..., includeFactors = FALSE, useDT = TRUE, DTstyle = TRUE)

\method{summaryTable}{paradata}(x, ..., useDT = TRUE, DTstyle = TRUE)
}
\arguments{
\item{x}{exportClass object.}

\item{...}{further arguments.}

\item{includeFactors}{if \code{TRUE}, factor variables will be converted to numeric and included in the table.}

\item{useDT}{Logical, if TRUE (default) the function returns a DataTable (DT) object (HTML table), otherwise
a data.table object is returned.}

\item{DTstyle}{if \code{TRUE} and \code{useDT = TRUE}, then a custom style will be applied, otherwise a plain DT table will be returned.}
}
\value{
A DataTable (DT) object (HTML table) displaying the summary statistics, if \code{useDT = TRUE}, and a plain data.table otherwise.
}
\description{
This function generates a summary table of numeric variables in an exportClass
object.
}
\details{
\itemize{
\item For the main data: The table includes statistics such as mean, standard deviation, maximum, minimum, and total
count as well as count of NA values.
}

\itemize{
\item For paradata: Different summary tables for response times, duration times etc. see examples.
}
}
\examples{
\dontrun{
questlist<-suso_getQuestDetails()

### MAIN DATA
export <- suso_export(questID = questlist$QuestionnaireId[7],
                      version = questlist$Version[7],
                      combineFiles = T,
                      reloadTimeDiff = 20)

# Create a summary table
summary_data_table <- summaryTable(export)

# Display the summary table
summary_data_table



}

\dontrun{
questlist<-suso_getQuestDetails()

### PARADATA
# 1. Pre-Processed tables created during export
para<-suso_export_paradata(questID = questlist$QuestionnaireId[1],
                          version = questlist$Version[1], reloadTimeDiff = 24,
                          workStatus = "All", asList = F, onlyActiveEvents = T)

# Create a summary table of all event counts by action (includes always passive and active one)
actions <- summaryTable(para, "action")

# Create a summary table of all event counts by user
users <- summaryTable(para, "user")

# 2. Tables created on request for response times
# grouped by variables, i.e. type, VariableName, responsible etc.

# Create a summary table of the average response time by variable
resptime_var <- summaryTable(para, "VariableName")

# Create a summary table of the average response time by question type
resptime_type <- summaryTable(para, "type")

# Create a summary table of the average response time by user
resptime_user <- summaryTable(para, "responsible")


}

}
