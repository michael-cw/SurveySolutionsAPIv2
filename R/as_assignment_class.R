#' Assignment Classes & Methods
#'
#' Assignments class extends the data.table class to include relevant methods
#'
#'
#'
#' @param x list returned by api call
#' @param ... additional attributes to be added to the assignmentClass
#'
#' @return assignmentClass object
#'
#' @details The assignmentClass is a data.table extended with additional attributes and methods, depending
#' on the api endpoint. The assignmentClass is used as input for the \code{getinfo} function.
#'
#'
#'
#' @export
#'
#' @examples
#' ass_list <- list(Assignments = data.frame(Id = 1, ResponsibleName = "interviewer1"))
#' ac <- assignmentClass(ass_list)
#' is.assignmentClass(ac)

assignmentClass<-function(x, ...) {
  nx<-names(x)
  if("Assignments" %in% nx) {
    iddt<-data.table::data.table(x$Assignments)
    attrloop<-names(x)[names(x)!="Assignments"]
  } else if("IdentifyingData" %in% nx) {
    iddt<-data.table::data.table(x$IdentifyingData)
    attrloop<-names(x)[names(x)!="IdentifyingData"]
  } else {
    iddt<-data.table::data.table()
    attrloop<-names(x)
  }
  ## define new class with data.table
  data.table::setattr(iddt, "class", base::union("assignmentClass", class(iddt)))
  ## add other information as attributes by loop over remaining names
  for(attr in attrloop) {
    data.table::setattr(iddt, tolower(attr), x[[attr]])
  }

  # ... must be non empty named list-->Contains all arguments passed to the function EXPLICITLY
  dots <- list(...)
  if(length(dots) > 0) {
    for(attr in names(dots)) {
      data.table::setattr(iddt, tolower(attr), dots[[attr]])
    }
  }
  invisible(iddt)
}

#' assignmentClass methods
#'
#' \code{getinfo} allows you to retrieve relevant additional information from the \code{assignmentClass},
#' object depending on the api endpoint.
#'
#' @details To retrieve all availalbe arguments use \code{arg="arglist"}
#'
#'
#' @param obj object of assignmentClass
#' @param arg name of attribute, if \code{arg="arglist"} then it returns all available arguments
#'
#' @return the specific attribute
#'
#'
#' @examples
#' \dontrun{
#'
#' # retrieve the uid of the person responsible after retrieving details for specific assignment
#' getinfo(asslist, "responsibleid")
#'
#' # see all available attribute names
#' getinfo(asslist, "arglist")
#'
#' }
#'
#' @export
#'
getinfo <- function(obj, arg) {
  UseMethod("getinfo")
}

#' @rdname getinfo
#' @export
getinfo.assignmentClass <- function(obj, arg) {
  if(arg=="arglist"){
    al<-names(attributes(obj))
    al<-al[!(al %in% c("names","row.names","class",".internal.selfref"))]
    return(al)
  } else {
    attr(obj, arg)
  }
}


#' Function to check if an object is of class assignmentClass
#'
#' @param x object to be checked
#'
#' @return TRUE if object is of class assignmentClass
#'
#' @export
#'
#' @examples
#' ac <- assignmentClass(list(Assignments = data.frame(Id = 1)))
#' is.assignmentClass(ac)
#' is.assignmentClass(data.frame())

is.assignmentClass <- function(x) {
  inherits(x, "assignmentClass")
}
