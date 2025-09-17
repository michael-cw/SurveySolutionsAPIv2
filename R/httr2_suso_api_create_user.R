#' Survey Solutions API call for User Creation
#'
#'
#' Creates Survey Solutions users (observers, interviewers or supervisors).
#'
#' @param userlist dataframe with upload data
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param showUser userName in console
#'
#'
#' @details Dataframe needs to be provided with the mandatory columns
#' for user creation which are: Role, UserName, Password and Supervisor (in case of interviewer),
#' optional you can also provide FullName, PhoneNumber and Email. Return value is a data.table, which includes
#' the user information as well as the response's status code. Important is also that the UserName and Password are
#' provided in the required format.
#'
#'
#' @export
#'
#'

suso_createUSER <- function(userlist = NULL,
                            server = suso_get_api_key("susoServer"),
                            apiUser = suso_get_api_key("susoUser"),
                            apiPass = suso_get_api_key("susoPass"),
                            workspace = suso_get_api_key("workspace"),
                            token = NULL,
                            showUser = FALSE) {


  # Default workspace
  workspace <- .ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check userlist
  if(is.null(userlist)) {
    cli::cli_abort(c("x" = "No userlist provided!"))
  }

  # B. Check if is data.table if not transform to data.table
  if (!is.data.table(userlist)) {
    userlist <- data.table::as.data.table(userlist)
  } else {
    # C. Copy data.table to avoid side effects
    userlist <- data.table::copy(userlist)
  }
  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "users")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "users")
  }

  ## Check user file
  ## 1. check mandatory variables
  vn<-names(userlist)
  if(!(sum(c("Role", "UserName", "Password", "Supervisor") %in% vn)==4)) {
    cli::cli_abort(c("x" = "Not all mandatory variables provided in the userlist"))
  }

  ## 2. check optional variables
  if(!("FullName" %in% vn)) {
    userlist$FullName<-character(nrow(userlist))
  }
  if(!("PhoneNumber" %in% vn)) {
    userlist$PhoneNumber<-character(nrow(userlist))
  }
  if(!("Email" %in% vn)) {
    userlist$Email<-character(nrow(userlist))
  } else {
    # CHECK EMAIL
  }

  # CHECK USERNAME


  # CHECK PASSWORD


  # SPLIT USERS BY SUPERVISOR AND INTERVIEWERS & mcreate SV first
  SV<-userlist[Role=="Supervisor"]
  INT<-userlist[Role=="Interviewer"]
  rm(userlist)
  allusers<-list(SV, INT)
  # loop over sv first, then int
  status_list_all<-list()
  for(k in seq_along(allusers)){
    userlist<-allusers[[k]]
    # Loope to vectorize the userlist into vectors with the same name
    for (col_name in names(userlist)) {
      assign(col_name, userlist[[col_name]])
    }

    # H. Request
    # H.1. Function to generate requests
    genrequests<- function(i) {
      js_ch <- list(
        Role = unbox(Role[i]),
        UserName = unbox(UserName[i]),
        FullName = unbox(FullName[i]),
        PhoneNumber = unbox(PhoneNumber[i]),
        Password = unbox(Password[i]),
        Supervisor = unbox(Supervisor[i])
      )

      req <- url |>
        # req_error(body = .http_error_body) |>
        # req_error(body = \(resp) last_response()) |>
        req_body_json(js_ch)  |>
        req_method("POST")
      # requires error handler to return response!!
      # req_error(body = .http_error_body)

      return(req)
    }
    # H.2. Execute request generation
    rol<-ifelse(k==1, "Supervisors", "Interviewers")
    if(interactive()){
    pgtext<-sprintf("Creating requests for %s in workspace %s.", rol ,workspace)
    requests <- lapply(cli::cli_progress_along(1:nrow(userlist), pgtext), genrequests)
    } else {
      requests <- lapply(seq_along(1:nrow(userlist)), genrequests)
    }
    # cli::cli_progress_along(allsv$UserId, pgtext, length(allsv$UserId)), .svget, allsv$UserId
    # if(TRUE) next

    # H.3. Perform requests in parallel
    responses <- httr2::req_perform_parallel(
      requests,
      max_active = getOption("suso.maxpar.req"),
      on_error = "continue"
    )

    # I. Response
    # I.1. Get faild responses
    failed <- responses |> httr2::resps_failures()
    # I.2. Get successful responses
    # success <-responses |> httr2::resps_successes()
    # I.2.1. Check if there are any successful responses and stop if not
    if(interactive() && length(failed)>0){ #length(failed)==0
      cli::cli_div(theme = list(span.emph = list(color = "red")))
      cli::cli_alert_danger("
      {.emph Some Users could not be created.}
      Out of {nrow(userlist)} {rol}, {length(failed)} could not be created.
      Please check the {.emph Error.} column in the data for details.\n\n")
      cli::cli_end()
    }

    # # I.3. Get response content
    .transformresponse<-function(i) {
      # check object first and if http error then
      status<-unclass(responses[[i]])$status
      if(status==400) {
        # i. Convert to json
        respdata<-jsonlite::fromJSON(rawToChar(unclass(responses[[i]])$resp$body))
        tmp <-data.table::data.table(t(unlist(respdata)))
        tmpe<-names(tmp)[grepl("^Errors.", names(tmp))]
        tmp<-tmp[,.SD, .SDcols = tmpe]
        # tmp<-data.table::data.table(t(unlist(tmp)))
        tmp<-cbind(userlist[i,], tmp)
        tmp$status_code<-status
      } else if(status==200) {
        # i. Convert to json
        tmp <-responses[[i]] |>
          resp_body_json(simplifyVector = T, flatten = TRUE)
        # ii. Transform to data.table
        tmp<-data.table::data.table(t(unlist(tmp)))
        tmp<-cbind(userlist[i,], tmp)
        tmp$status_code<-status
      } else {
        # i. Convert to json
        respdata<-jsonlite::fromJSON(rawToChar(unclass(responses[[i]])$resp$body))
        tmp <-data.table::data.table(t(unlist(respdata)))
        tmpe<-names(tmp)[grepl("^Errors.", names(tmp))]
        tmp<-tmp[,.SD, .SDcols = tmpe]
        # tmp<-data.table::data.table(t(unlist(tmp)))
        tmp<-cbind(userlist[i,], tmp)
        tmp$status_code<-status
      }

      return(tmp)
    }

    if(interactive()){
      pgtext<-sprintf("Extracting responses for %s in workspace %s.", rol ,workspace)
      status_list <- lapply(cli::cli_progress_along(1:length(responses), pgtext), .transformresponse)
    } else {
      status_list <- lapply(seq_along(1:length(responses)), .transformresponse)
    }

    # I.3.2. Convert to data.table and bind
    status_list_all[[k]]<-data.table::rbindlist(status_list, fill = TRUE)
  }
  # I.3.2. Convert to data.table and bind
  status_list_all<-data.table::rbindlist(status_list_all, fill = TRUE)


  return(status_list_all)

}
