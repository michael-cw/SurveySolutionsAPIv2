#' Survey Solutions API credentials
#'
#'
#' (this function has been inspired by the googleway package
#' \url{https://github.com/SymbolixAU/googleway},
#' an excellent package to use google geo-spatial API)
#' Retrieves the list of Survey Solutions credentials that have been set.
#'
#' @return A list of class suso_api containing current Survey Solutions credentials.
#' @export
#' @import readr
#' @import stringr
#'
#' @examples
#' suso_keys()
suso_keys <- function() getOption("SurveySolutionsAPI")


# #'
# #' @export
# print.suso_api <- function(x, ...) {
# 
#   for (i in 1:length(x)) {
# 
#     cli::cli_alert_info("Survey Solutions API credentials\n")
# 
#     for (j in 1:length(x[[i]])){
#       cat(" - ", names(x[[i]])[j], ": ")
#       key <- x[[i]][[j]]
#       cat(ifelse(is.na(key), "", key), "\n")
#     }
#   }
# }

#' Set all credentials at once
#'
#' Sets API credentials so it's available for all API calls. See details
#'
#' @param suso_server Survey Solutions server address
#' @param suso_user Survey Solutions API user
#' @param suso_password Survey Solutions API password
#' @param suso_token If Survey Solutions server token is provided \emph{suso_user} and \emph{suso_password} will be ignored
#' @param workspace server workspace Name, if nothing provided, defaults to primary
#'
#' @details
#' Use \code{suso_set_key} to make API keys available for all the \code{suso_}
#' functions, so you don't need to specify the credentials parameter within those
#' functions. The server address can be provided with or without https:\\ suffix,
#' nevertheless if it is missing, then the suffix will be added. For testing purposes
#' it also allows for http connections, however for publicly accessible servers
#' we do not recommend unencrypted connections.
#'
#' In case \emph{suso_token} is provided, only token authentication will be attempted. For details on token authentication
#' in Survey Solutions please see \url{https://docs.mysurvey.solutions/headquarters/accounts/token-based-authentication/}.
#'
#'
#' @return Invisible NULL.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_set_key(
#'   suso_server = "https://demo.mysurvey.solutions",
#'   suso_user = "api_user",
#'   suso_password = "password123",
#'   workspace = "primary"
#' )
#' }
#'
suso_set_key <- function(
  suso_server = "",
  suso_user = "",
  suso_password = "",
  workspace = NULL,
  suso_token = ""
) {
  # workspace default
  workspace<-.ws_default(ws = workspace)
  # get options
  options <- getOption("SurveySolutionsAPI")
  ###########################################
  # sanitize string to ssl (http?)
  if(!getOption("suso.url.http")){ 
    suso_server<-ifelse(stringr::str_count(suso_server, "https://")==1,
                        suso_server, paste0("https://", suso_server))
  } else if(getOption("suso.url.http")){ 
    suso_server<-ifelse(stringr::str_count(suso_server, "http://")==1,
                        suso_server, paste0("http://", suso_server))
  } 
  
  # check if ends w slash
  suso_server<-.addSlashToEnd(suso_server)
  # add to object
  options[['suso']][['susoServer']] <- suso_server
  options[['suso']][['susoUser']] <- suso_user
  options[['suso']][['susoPass']] <- suso_password
  options[['suso']][['workspace']] <- workspace
  class(options) <- "suso_api"
  options(SurveySolutionsAPI = options)
  invisible(NULL)

}

#' Convenience function to switch workspace
#'
#' Sets the workspace only, but leaves all other credentials the same.
#'
#' @param workspace server workspace Name (not the display name), if nothing provided, defaults to primary
#'
#' @details
#' Use \code{suso_set_workspace} to make the desired workspace available for all the \code{suso_}
#' functions, so you don't need to specify the workspace parameter within those
#' functions. The function also checks if the workspace name is correct, and the user with the current credentials is
#' authorized.If the workspace requires different credentials, then use \code{\link{suso_set_key}} again.
#'
#' @return invisibly TRUE if successful.
#'
#' @examples
#' \dontrun{
#'
#' # switch to workspace "windows"
#' suso_set_workspace("windows")
#'
#' # switch to primary (default) workspace
#' suso_set_workspace()
#'
#' }
#'
#' @export
#'
suso_set_workspace <- function(
    workspace = NULL
) {
  # workspace default
  workspace<-.ws_default(ws = workspace)
  # check if ws exists and user is authorized
  wsauth<-suso_getWorkspace()$Name
  if(!(workspace %in% wsauth)) {
    cli::cli_abort(c("x" = "The provided workspace is not available. Either you used the wrong name, or you are not authorized. Please check!"))
  } else {
    if(interactive()) {
      cli::cli_div(theme = list(span.emph = list(color = "green",
                                                 `font-weight` = "bold")))
      cli::cli_alert_success("Workspace changed to: {.emph {toupper(workspace)}}")}
      cli::cli_end()
  }
  # get options
  options <- getOption("SurveySolutionsAPI")

  # add to object
  options[['suso']][['workspace']] <- workspace

  class(options) <- "suso_api"
  options(SurveySolutionsAPI = options)
  invisible(TRUE)

}


#' Clear Credentials
#'
#' Clears all the API credentials
#'
#' @return Invisible NULL.
#' @export
#'
#' @examples
#' suso_clear_keys()
suso_clear_keys <- function() {

  options <- list(
    suso = list(
      susoServer = NA_character_,
      susoUser = NA_character_,
      susoPass = NA_character_,
      workspace = NA_character_
    )
  )
  attr(options, "class") <- "suso_api"
  options(SurveySolutionsAPI = options)

  if(interactive()) {
    cli::cli_alert_success("Survey Solutions credentials are cleared!")
  }

}

#' Get credentials
#'
#' Get API credentials
#'
#' Get credentials, used as input in API calls
#'
#' @param api one of susoServer, susoUser, susoPass, or workspace
#'
#' @return Character string of the requested credential, or NA if not set.
#' @import data.table
#'
#' @export
#'
#' @examples
#' suso_get_api_key("susoServer")
#' suso_get_api_key("workspace")
#'
suso_get_api_key <- function(api = c("susoServer", "susoUser", "susoPass", "workspace")) {

  rlang::arg_match(api)
  ## Return value for selected API component
  api <- getOption("SurveySolutionsAPI")[['suso']][[api]]
  #if(is.na(api)) return(suso_get_default_key(api))

  return(api)
}

#' Checks if credentials are present
#'
#' Helper function
#'
#' @param api one of susoServer, susoUser, susoPass, or workspace
#'
#' @return Character string of the requested credential, or throws error if not set.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_get_default_key("susoServer")
#' }
suso_get_default_key <- function(api = c("susoServer", "susoUser", "susoPass", "workspace")) {
  rlang::arg_match(api)
  key <- getOption("SurveySolutionsAPI")[['suso']][[api]]
  if(is.na(key)) withr::with_options(
    list(rlang_backtrace_on_error = "none"),
    cli::cli_abort(
    c("x" ="No API credentials available! Use either suso_set_key() to set a key, or provide it as a function argument directly")
    ))
  return(key)
}


#' Utility function to check if credentials are correct
#'
#' This function returns a 200 status code if credentials are correct and a 400 code otherwise.
#'
#' @param server Survey Solutions Server
#' @param apiUser API user
#' @param apiPass API password
#' @param workspace server workspace Name, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#'
#' @return 200 code if correct, 400 if incorrect.
#'
#' @details
#' If the app runs interactively, status is printed to the console, if it runs in a shiny app, a status
#' notification will be shown, if option \option{suso.useshiny} is \code{TRUE}.
#'
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' suso_PwCheck(
#'   server = "https://demo.mysurvey.solutions",
#'   apiUser = "api_user",
#'   apiPass = "password123"
#' )
#' }
suso_PwCheck<-function(server=suso_get_api_key("susoServer"),
                       apiUser=suso_get_api_key("susoUser"),
                       apiPass=suso_get_api_key("susoPass"),
                       workspace = suso_get_api_key("workspace"),
                       token = NULL) {
  if(is.na(server) | is.na(apiUser) | is.na(apiPass)) {
    # return 400 if any is missing
    return(400)
  }
  # check internet connection
  if(!(curl::has_internet())) {
    withr::with_options(
      list(rlang_backtrace_on_error = "none"),
      cli::cli_abort(c("x"="No internect connection available! Please check the connection before proceeding."))
    )
  }
  ## workspace default
  workspace<-.ws_default(ws = workspace)
  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "supervisors")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "supervisors")
  }

  # add query
  url<-.addQuery(url, limit=200)

  ## Request
  test_detail<-tryCatch(
    {req_perform(url) |> resp_status()},
    error=function(e) {a<-400; return(a)}
  )
  # if interactive, print message & query
  if(!shiny::isRunning() && interactive()){
    cli::cli_div(theme = list(span.emph = list(color = "green",
                                               `font-weight` = "bold")))
    if(test_detail==200){
      cli::cli_alert_success("Credentials are correct and the following successful request\n was performed in workspace {.emph  {toupper(workspace)}} :\n\n")
      url |> httr2::req_dry_run()

    } else {
      cli::cli_alert_danger("Credentials are incorrect & and the following failed request was performed in workspace {.emph  {toupper(workspace)}}:\n\n")
      url |> httr2::req_dry_run()
    }
    cli::cli_end()
  } else if(shiny::isRunning() && getOption("suso.useshiny")) {
    # if in shiny, show notification
    if(test_detail==200){
      shiny::showNotification(sprintf("Credentials are correct and a successful
                              request\n was performed in workspace %s", workspace), type = "warning")


    } else {
      shiny::showNotification(sprintf("Credentials are incorrect and a failed
                              request\n was performed in workspace %s", workspace), type = "error")
    }

  }

  return(test_detail)
}




















