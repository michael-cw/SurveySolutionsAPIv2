#' Survey Solutions API call for workspace information
#'
#'
#' \code{suso_getWorkspace} allows you to get the list of workspaces, information about individual workspace names
#' as well as workspace statuses. Workspaces as well as Workspaces information can only be accessed, if credentials
#' are eligible. For more details please read \url{https://docs.mysurvey.solutions/headquarters/accounts/workspaces/}
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param workspace If workspace name is provide requests are made regarding this specific workspace
#' @param status if status is \emph{TRUE} worskpace must be not NULL and status information about a specific
#' workspace is requested
#'
#' @examples
#' \dontrun{
#' # This assumes, that suso_PwCheck(workspace = "myworkspace") was
#' # sucessful
#'
#' # shows all workspaces in the system AND the user has access to
#' suso_getWorkspace(
#'           status = F)
#'
#' # shows details for specific workspace myworkspace
#' suso_getWorkspace(
#'           workspace = "myworkspace",
#'           status = T)
#' }
#'
#'
#' @export


suso_getWorkspace <- function(server = suso_get_api_key("susoServer"),
                              apiUser = suso_get_api_key("susoUser"),
                              apiPass = suso_get_api_key("susoPass"),
                              token = NULL,
                              workspace = NULL,
                              status = FALSE) {
  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, NULL, token, "workspaces")
  } else {
    url<-.baseurl_baseauth(server, NULL, apiUser, apiPass, "workspaces")
  }

  if(is.null(workspace)) {
    tryCatch(
      {resp<-req_perform(url)},
      error = function(e) .http_error_handler(e, "wsp")
    )
    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = T, flatten = F)
        # Export only records
        test_json<-data.table(test_json$Workspaces)
        # Set date time to utc with lubridate
        return(test_json[])
      }
    } else {
      return(data.table(NULL))
    }
  } else if(!is.null(workspace)) {
    if(status) {
      url<- url |>
        req_url_path_append("status") |>
        req_url_path_append(workspace)
    } else {
      url<- url |>
        req_url_path_append(workspace)

    }

    tryCatch(
      {resp<-req_perform(url)},
      error = function(e) .http_error_handler(e, "wsp")
    )
    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = T, flatten = F)
        # Export only records
        test_json<-data.table(t(test_json))
        # Set date time to utc with lubridate
        return(test_json[])
      }
    } else {
      return(data.table(NULL))
    }


  }

}


#' Survey Solutions API call to create workspace
#'
#'
#' @description \code{suso_createWorkspace} Allows you to create a workspace with a specific system name and display name.
#' For more details please read \url{https://docs.mysurvey.solutions/headquarters/accounts/workspaces/}. To run this command
#' you require admin credentials.
#'
#' @details Be aware, that for using this call you require the ADMIN credentials, and not the regular API user credentials.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions ADMIN user
#' @param apiPass Survey Solutions ADMIN password
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param new_workspace The name used by the system for this workspace. Make sure you follow the nameing rules outlined
#' under \url{https://docs.mysurvey.solutions/headquarters/accounts/workspaces/}
#' @param displayName The name visible to the users
#'
#' @examples
#' \dontrun{
#' # Use Admin Credentials!
#' suso_createWorkspace(
#'           new_workspace = "myworkspace1",
#'           displayName = "SpecialWorkspace",
#'           apiUser = "xxxxxx",
#'           apiPass = "xxxxxx")
#' }
#'
#'
#' @export


suso_createWorkspace <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 token = NULL,
                                 new_workspace = NULL,
                                 displayName = NULL) {

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  if(is.null(new_workspace)) cli::cli_abort(c("x" = "Please provide a new workspace name"))

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, NULL, token, "workspaces")
  } else {
    url<-.baseurl_baseauth(server, NULL, apiUser, apiPass, "workspaces")
  }
  url<- url |>
    req_body_json(
      list(Name=new_workspace, DisplayName=displayName)
    ) |>
    req_method("POST")
  tryCatch(
    {resp<-req_perform(url)},
    error = function(e) .http_error_handler(e, "wsp")
  )
  # get the response data
  if(resp_has_body(resp)){
    # get body by content type
    if(resp_content_type(resp) == "application/json") {
      test_json<-resp_body_json(resp, simplifyVector = T, flatten = F)
      # Export only records
      test_json<-data.table(t(test_json))
      # Set date time to utc with lubridate
      return(test_json[])
    }
  } else {
    return(data.table(NULL))
  }


}



#' Survey Solutions API call to assign workspace (!! WORKS ONLY WITH ADMIN CREDENTIALS)
#'
#'
#' @description \code{suso_assignWorkspace} Allows you to assign a workspace to a specific user or a group of users.
#' For more details please read \url{https://docs.mysurvey.solutions/headquarters/accounts/workspaces/}. To run this command
#' you require admin credentials and not the regular API user credentials.
#'
#' @param server Survey Solutions server address.
#' @param apiUser Survey Solutions ADMIN user.
#' @param apiPass Survey Solutions ADMIN password.
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored.
#' @param assign_workspace The workspace which you want to assign to the new user.
#' @param keep_old_workspace if TRUE, exsting assigned workspaces will be kept, if FALSE only the new one will be assigned, see details.
#' @param uid Either a single User ID of the user to be assigned, or a vector.
#' @param sv_id The supervisor's ID to which the interviewer should be assigned to, if it is a supervisor who is assigned, just use the same
#' as in \emph{uid}. Must be the same length as \code{uid}
#'
#' @details
#' When \code{keep_old_workspace=FALSE} the user will only be assigned to the new workspace, otherwise the existing ones will be added, if the former
#' is the case, then you need to make sure, that all assignments, interviews, team members etc. are cleared in the old workspace. Be aware,
#' that for using this call you require admin credentials, and not the regular API user credentials.
#'
#'
#' @return If successful, returns a data.table with the details as well as the Status message \code{workspace list updated}.
#'
#' @examples
#' \dontrun{
#' ## Use Admin Credentials!
#'
#' # Assign a new workspace to a single user, keep old one(s)
#' suso_assignWorkspace(
#'           assign_workspace = "myworkspace1",
#'           uid = "xxx-xxx-xxx-xxx-xxx",
#'           sv_id = "xxx-xxx-xxx-xxx-xxx",
#'           apiUser = "xxxxxx",
#'           apiPass = "xxxxxx",
#'           keep_old_workspace = TRUE
#'           )
#'
#' # Assign a new workspace to a single user, drop old one(s)
#' suso_assignWorkspace(
#'           assign_workspace = "myworkspace1",
#'           uid = "xxx-xxx-xxx-xxx-xxx",
#'           sv_id = "xxx-xxx-xxx-xxx-xxx",
#'           apiUser = "xxxxxx",
#'           apiPass = "xxxxxx",
#'           keep_old_workspace = TRUE
#'           )
#'
#' # Assign all supervisors from on workspace to a new one, keep old one
#' allsv<-suso_getSV(workspace = old)
#' suso_assignWorkspace(
#'           assign_workspace = "new",
#'           uid = "allsv$UserId,
#'           sv_id = allsv$UserId,
#'           apiUser = "xxxxxx",
#'           apiPass = "xxxxxx",
#'           keep_old_workspace = TRUE
#'           )
#'
#' # Assign all interviewers from on workspace to a new one, keep old one
#' allint<-suso_getINT(workspace = old)
#' suso_assignWorkspace(
#'           assign_workspace = "new",
#'           uid = "allint$UserId,
#'           sv_id = allint$sv_id,
#'           apiUser = "xxxxxx",
#'           apiPass = "xxxxxx",
#'           keep_old_workspace = TRUE
#'           )
#'
#' }
#'
#'
#' @export


suso_assignWorkspace <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 token = NULL,
                                 assign_workspace = NULL,
                                 keep_old_workspace = TRUE,
                                 uid = NULL,
                                 sv_id = NULL) {


  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check if questID is provided & correct
  if(is.null(uid)){
    cli::cli_abort("Please provide a User ID")
  } else {
    # checks only first element, assumes rest is same
    .checkUUIDFormat(uid[1])
  }

  # if(is.null(sv_id)){
  #   cli::cli_abort("Please provide a Supervisor ID")
  # } else {
  #   .checkUUIDFormat(sv_id)
  # }

  if(is.null(assign_workspace)) cli::cli_abort(c("x" = "Please provide a workspace name"))

  # Backup of ws for message in pg bar
  assign_workspace_new<-assign_workspace

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, NULL, token, "workspaces/assign")
  } else {
    url<-.baseurl_baseauth(server, NULL, apiUser, apiPass, "workspaces/assign")
  }

  # single user
  if(length(uid) == 1) {
    # old ws
    if(keep_old_workspace) {
      ep<-paste0(server, "graphql")
      usr<-apiUser
      p<-apiPass
      wsold<-susographql::suso_gql_users(
        endpoint = ep,
        user = usr,
        password = p,
        id = stringr::str_remove_all(uid, "-")
      )$users$nodes$workspaces

      assign_workspace<-unique(c(assign_workspace, wsold[[1]]))
      sv_id<-rep(sv_id, length(assign_workspace))
    }
    js_ch<-list(
      UserIds=I(uid),
      Workspaces=data.table(
        Workspace=assign_workspace,
        SupervisorId=sv_id
      ),
      Mode=jsonlite::unbox("Assign")
    )
    url<- url |>
      req_body_json(
        js_ch
      ) |>
      req_method("POST")

    tryCatch(
      {resp<-req_perform(url)},
      error = function(e) .http_error_handler(e, "wsp")
    )

    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = T, flatten = F)
        # Export only records
        test_json<-data.table((test_json$Errors))
        # Set date time to utc with lubridate
        return(test_json[])
      }
    } else {
      test_json<-data.table::data.table(UserIds = uid, Workspace = assign_workspace, SupervisorId = sv_id, Status = "Workspaces list updated")
      return(test_json)
    }
  } else if(length(uid)>1) {
    # old ws
    if(keep_old_workspace) {
      ep<-paste0(server, "graphql")
      usr<-apiUser
      p<-apiPass
      getwsold<-function(uid, ...) {
        wsold<-susographql::suso_gql_users(
          endpoint = ep,
          user = usr,
          password = p,
          id = stringr::str_remove_all(uid, "-")
        )$users$nodes$workspaces
        ws<-unique(c(assign_workspace, wsold[[1]]))
        return(ws)
      }
      # Now a matrix with one row for each uid
      assign_workspace<-t(sapply(uid, getwsold, assign_workspace, USE.NAMES = F, simplify = T))

      # define the expression for the loop
      js_ch<-rlang::expr(
        list(
          UserIds=I(args$uid[i]),
          Workspaces=data.table(
            Workspace=args$assign_workspace[i,],
            SupervisorId=args$sv_id[i]
          ),
          Mode=jsonlite::unbox("Assign")
        )
      )
    } else {
      ## NEW WORKSPACE ONLY
      # define the expression for the loop
      js_ch<-rlang::expr(
        list(
          UserIds=I(args$uid[i]),
          Workspaces=data.table(
            Workspace=args$assign_workspace,
            SupervisorId=args$sv_id[i]
          ),
          Mode=jsonlite::unbox("Assign")
        )
      )
    }


    # Generate the requests
    requests<-.gen_lapply_with_progress(
      1:length(uid),
      .genrequests_w_jsonbody,
      "requests", "workspace assignments", assign_workspace_new,
      url, js_ch, uid = uid, sv_id = sv_id, assign_workspace = assign_workspace
    )
    # execute requests in parallel
    responses <- httr2::req_perform_parallel(
      requests,
      max_active = getOption("suso.maxpar.req"),
      on_error = "return"
    )

    # generate response for successfull requests
    if(length(responses) == 0) {
      cli::cli_alert_danger(c("x" = "No successfull requests. Please check your inputs. Did you use admin credentials?"))
      return(data.table(NULL))
    } else {
      test_json<-vector("list", length = length(responses))
      for(i in seq_along(responses)) {
        test_json[[i]]<-data.table::data.table(
          UserIds = uid[i],
          Workspace = assign_workspace[i,],
          SupervisorId = sv_id[i],
          Status = "Workspaces list updated")
      }

      test_json<-rbindlist(test_json)
      return(test_json)
    }
  }

}














