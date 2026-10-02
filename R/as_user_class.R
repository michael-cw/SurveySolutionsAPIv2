#' User Classes & Methods
#'
#' Users class extends the data.table class to include relevant methods
#'
#'
#'
#' @param x list returned by api call
#' @param ... additional attributes to be added to the assignmentClass
#'
#' @return An object of class UserClass (inheriting from data.table)
#' @export
#'
#' @examples
#' usr_list <- list(Users = data.frame(UserName = "interviewer1", Role = "Interviewer"))
#' uc <- UserClass(usr_list)
#' is.UserClass(uc)

UserClass<-function(x, ...) {
  nx<-names(x)
  if("Users" %in% nx) {
    iddt<-data.table::data.table(x$Users)
    attrloop<-names(x)[names(x)!="Users"]
  } else if("IdentifyingData" %in% nx) {
    iddt<-data.table::data.table(x$IdentifyingData)
    attrloop<-names(x)[names(x)!="IdentifyingData"]
  } else {
    iddt<-data.table::data.table()
    attrloop<-names(x)
  }
  ## define new class with data.table
  data.table::setattr(iddt, "class", base::union("UserClass", class(iddt)))
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

#' @rdname getinfo
#' @export
getinfo.UserClass <- function(obj, arg) {
  if(arg=="arglist"){
    al<-names(attributes(obj))
    al<-al[!(al %in% c("names","row.names","class",".internal.selfref"))]
    return(al)
  } else {
    attr(obj, arg)
  }
}


#' Function to check if an object is of class UserClass
#'
#' @param x object to be checked
#'
#' @return TRUE if object is of class UserClass
#'
#' @export
#'
#' @examples
#' uc <- UserClass(list(Users = data.frame(UserName = "interviewer1")))
#' is.UserClass(uc)
#' is.UserClass(data.frame())

is.UserClass <- function(x) {
  inherits(x, "UserClass")
}


#' S3 method to create a summary table of users for UserClass object
#'
#' This function generates a summary table of Users.
#'
#' @param x A UserClass object.
#' @param includeFactors if \code{TRUE}, factor variables will be converted to numeric and included in the table (only for exportClass).
#' @param useDT Logical, if TRUE (default) the function returns a DataTable (DT) object (HTML table), otherwise
#' a data.table object is returned.
#' @param DTstyle if \code{TRUE} and \code{useDT = TRUE}, then a custom style will be applied, otherwise a plain DT table will be returned.
#' @param ... Additional arguments (not used).
#'
#' @return A DataTable (DT) object (HTML table)  if \code{useDT = TRUE}, and a plain data.table otherwise. The table contains
#' all users core data, plus completed and assigned counts,
#'
#' @details
#' For very large tables you will get a warning when rendering in Rstudio, however in a shiny app you have the option to use
#' server side processing: \code{DT::renderDataTable(..., server = TRUE)}. In cases where \code{future} and \code{future.apply} is
#' available on your system the additional information will be retrieved in parallel (multisession), otherwise sequential. For large
#' data sets parallel processing is recommended. Furthermore when processing in parallel,
#' a progress bar for shiny applications is included and active when running in a shiny application, otherwise a cli progress bar will
#' be displayed.
#'
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' allintprim<-suso_getINT(workspace = "primary")
#'
#' # Create a summary table
#' summary_data_table <- summaryTable(allintprim)
#'
#' # Display the summary table
#' summary_data_table
#' }
#'
summaryTable.UserClass <- function(x, includeFactors = FALSE, useDT = TRUE, DTstyle = TRUE, ...) {

  # check if x is of class exportClass
  if (!is.UserClass(x)) {
    cli::cli_abort(c("x" = "x must be of class exportClass."))
  }

  if (nrow(x)==0) {
    cli::cli_abort(c("x" = "Table is empty."))
  } else {
    summary_data<-x
  }

  ### Add completed interview count to table for each user with future/future.apply (only if installed)
  intids<-summary_data[["UserName"]]
  ep<-paste0(suso_get_api_key("susoServer"), "graphql")
  usr<-suso_get_api_key("susoUser")
  p<-suso_get_api_key("susoPass")
  ws<-suso_get_api_key("workspace")

  if ((rlang::is_installed("future") & rlang::is_installed("future.apply"))) {
    if(interactive()){
      cli::cli_alert_success(c("Package future and future.apply found on your system. Proceeding with parallel operation."))
    }
    oplan<-future::plan("multisession")
    on.exit(future::plan(oplan))
    nplan<-getOption("suso.para.plan")
    ncores<-getOption("suso.para.maxcore")
    if(nplan=="sequential") {
      #  with workers gives warning
      future::plan(nplan)
    } else {
      future::plan(nplan, workers = ncores)
    }
    gqlpar_w_progr<- function(x) {
      res<-susographql::suso_gql_interviews(
        endpoint = ep,
        user = usr,
        password = p,
        workspace = ws,
        responsibleName = x,
        status = "COMPLETED"
      )$interview$filteredCount

      prog(sprintf("%s", x))
      return(res)
    }

    progressr::handler_cli()
    if(!(shiny::isRunning())){
      progressr::handlers(global = T)
      # run outside shiny
      prog<-progressr::progressor(along = intids)
      compcount1<-future.apply::future_sapply(intids, gqlpar_w_progr , USE.NAMES = F)

    } else {
      # inside shiny
      progressr::withProgressShiny(
        message = "Retrieving Completion Counts",
        detail = "Loading ...",
        value = 0, {
          prog<-progressr::progressor(along = intids)
          compcount1<-future.apply::future_sapply(intids, gqlpar_w_progr , USE.NAMES = F)
        }
      )
    }

    # turn off future
    future::plan("sequential")
  } else {
    if(interactive()){
      cli::cli_alert_warning(c("Package future and future.apply not found on your system. Proceeding with seqential operation.
                             Depending on the size of your data, this may take some time. Consider installing these packages if you deall with
                             large data sets."))
    }
    compcount1<-sapply(intids, function(x) susographql::suso_gql_interviews(
      endpoint = ep,
      user = usr,
      password = p,
      workspace = ws,
      responsibleName = x,
      status = "COMPLETED"
    )$interviews$filteredCount, USE.NAMES = F)
  }
  # add completed count
  summary_data[,Completed:=compcount1]

  ### Add assigned interview count to table for each user with future/future.apply (only if installed)
  intids<-summary_data[["UserId"]]

  if ((rlang::is_installed("future") & rlang::is_installed("future.apply") & rlang::is_installed("progressr"))) {
    oplan<-future::plan("multisession")
    on.exit(future::plan(oplan))
    nplan<-getOption("suso.para.plan")
    ncores<-getOption("suso.para.maxcore")
    if(nplan=="sequential") {
      #  with workers gives warning
      future::plan(nplan)
    } else {
      future::plan(nplan, workers = ncores)
    }
    # function
    gqlpar_w_progr<- function(x) {
      res<-susographql::suso_gql_assignments(
        endpoint = ep,
        user = usr,
        password = p,
        workspace = ws,
        responsibleId = x
      )$assignments$filteredCount

      prog(sprintf("%s", x))
      return(res)
    }

    progressr::handler_cli()
    if(!(shiny::isRunning())){
      progressr::handlers(global = T)
      # run outside shiny
      prog<-progressr::progressor(along = intids)
      compcount1<-future.apply::future_sapply(intids, gqlpar_w_progr , USE.NAMES = F)

    } else {
      # inside shiny
      progressr::withProgressShiny(
        message = "Retrieving Assignment Counts",
        detail = "Loading ...",
        value = 0, {
          prog<-progressr::progressor(along = intids)
          compcount1<-future.apply::future_sapply(intids, gqlpar_w_progr , USE.NAMES = F)
        }
      )
    }

    # turn off future
    future::plan("sequential")
  } else {
    compcount1<-sapply(intids, function(x) susographql::suso_gql_interviews(
      endpoint = ep,
      user = usr,
      password = p,
      workspace = ws,
      responsibleId = x
    )$assignments$filteredCount, USE.NAMES = F)
  }
  # add ass count
  summary_data[,Assigned:=compcount1]

  ### If useDT is FALSE return the data.table
  if (!useDT) {
    # Return plain data.table
    return(summary_data[])
  } else {
    # Return DT
    # cli abort if DT is not found
    if (!(rlang::is_installed("DT"))) {
      cli::cli_abort(c("x" ="DT package is required to use this function and not found on your system."))
    }
    # GEN DT
    # define options
    if(DTstyle) {
      smTabDir <- list(
        dom = "t",
        pagelength = nrow(summary_data),
        paging = FALSE,
        fixedHeader = TRUE,
        # Solution for rowwise from: https://stackoverflow.com/questions/69812528/r-data-table-alternating-row-color-with-groupings
        initComplete = DT::JS(
          "function(settings, json) {",
          "$(this.api().table().header()).css({'background-color': '#002244', 'color': '#FFFFFF'});",
          "$('table.dataTable.display tbody tr.odd').css('background-color', '#FFFFFF');",
          "$('table.dataTable.display tbody tr.even').css('background-color', '#009FDA80');",
          "}"),
        columnDefs = list(list(className = 'dt-center', targets = c(0:(length(summary_data)-1))))
      )
    } else {
      smTabDir <- list(
        pagelength = nrow(summary_data),
        paging = FALSE
      )
    }

    # render
    DT<-DT::datatable(summary_data,
                      smTabDir, rownames = F
                      #style = "bootstrap4"
    ) |>
      DT::formatStyle(1:length(summary_data),
                      color = '#002244',
                      #backgroundColor = 'orange',
                      fontWeight = 'bold')

    # DT<-DT::datatable(summary_data)
    return(DT)
  }
}



