% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/as_assignment_class.R
\name{assignmentClass}
\alias{assignmentClass}
\title{Assignment Classes & Methods}
\usage{
assignmentClass(x, ...)
}
\arguments{
\item{x}{list returned by api call}

\item{...}{additional attributes to be added to the assignmentClass}
}
\value{
assignmentClass object
}
\description{
Assignments class extends the data.table class to include relevant methods
}
\details{
The assignmentClass is a data.table extended with additional attributes and methods, depending
on the api endpoint. The assignmentClass is used as input for the \code{getinfo} function.
}
