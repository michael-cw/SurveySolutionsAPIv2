#' Survey Solutions API call to retrieve all interviews for a specific questionnaire
#'
#' Returns all interviews for the specified questionnaire and the selected status.
#'
#' @details ATTENTION: This function only exists for consistency reasons with the original SurveySolutionsAPI package. Under the hood
#' it uses \code{\link{suso_getQuestDetails}}, which is based on the GraphQL API.
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID your Survey Solutions \emph{QuestionnaireId}. Retrieve a list of questionnaires by executing \code{suso_getQuestDetails}
#' @param version version of the questionnaire
#' @param workStatus define which statuses the file should inlude (i.e. \emph{Restored,Created,SupervisorAssigned,InterviewerAssigned,
#' RejectedBySupervisor,ReadyForInterview,
#' SentToCapi,Restarted,Completed,ApprovedBySupervisor,
#' RejectedByHeadquarters,ApprovedByHeadquarters,Deleted}), if NULL only completed interviews will be shown.
#'
#'
#' @examples
#' \dontrun{
#' To get all interviews for a specific questionnaire and a specific status
#'      suso_getAllInterviewQuestionnaire(
#'               workspace = "myworkspace",
#'               questID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'               version = 1,
#'               workStatus = "InterviewerAssigned"
#'               )
#' # or to get all interviews in status completed
#'      suso_getAllInterviewQuestionnaire(
#'               workspace = "myworkspace",
#'               questID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'               version = 1
#'               )
#'
#' }
#'
#' @return A data.table listing all interviews matching the specified questionnaire and status filter.
#' @export


suso_getAllInterviewQuestionnaire <- function(server= suso_get_api_key("susoServer"),
                                              apiUser=suso_get_api_key("susoUser"),
                                              apiPass=suso_get_api_key("susoPass"),
                                              workspace = suso_get_api_key("workspace"),
                                              token = NULL,
                                              questID = "",
                                              version = 1,
                                              workStatus=c("Completed", "All", "SupervisorAssigned", "InterviewerAssigned",
                                                           "RejectedBySupervisor",
                                                           "ApprovedBySupervisor",
                                                           "RejectedByHeadquarters",
                                                           "ApprovedByHeadquarters")
) {
  ######################################
  # Check arguments
  #  - workStatus
  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check if questID is provided & correct
  if(!is.null(questID)){
    .checkUUIDFormat(questID)
  }

  # check if version is provided & numeric
  if(!is.null(version)){
    .checkNum(version)
  }

  # check if operation.type is provided & correct
  workStatus <- match.arg(workStatus)

  test_json<-suso_getQuestDetails(operation.type = "interviews", questID = questID, version = version, workStatus = workStatus)
  return(test_json)
}



#' Survey Solutions API call to retrieve all answers for a specific interview
#'
#' Returns all responses for a specific interview
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param intID the \emph{InterviewId} of the interview. To get a list of all interview for a specific questionnaire, execute \code{suso_getAllInterviewQuestionnaire}
#'
#' @examples
#' \dontrun{
#' suso_getAllAnswerInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
#'           )
#'
#' }
#'
#' @return A data.table containing all answers for the given interview.
#' @export
#'
suso_getAllAnswerInterview <- function(server= suso_get_api_key("susoServer"),
                                       apiUser=suso_get_api_key("susoUser"),
                                       apiPass=suso_get_api_key("susoPass"),
                                       workspace = suso_get_api_key("workspace"),
                                       token = NULL,
                                       intID = "") {



  ## default workspace
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "interviews")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  # check int_id is uuid
  .checkUUIDFormat(intID)

  # append int_id to url
  url<-url |>
    req_url_path_append(intID)

  tryCatch(
    {resp<-req_perform(url)},
    error = function(e) .http_error_handler(e, "ass")
  )

  # get the response data
  if(resp_has_body(resp)){
    # get body by content type
    if(resp_content_type(resp) == "application/json") {
      test_json<-resp_body_json(resp, simplifyVector = T, flatten = F)
      # Export only records
      test_json<-data.table(test_json$Answers)
      # Set date time to utc with lubridate
      return(test_json)
    }
  } else {
    return(data.table(NULL))
  }

}



#' Get all history for a specific interview
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param intID the \emph{InterviewId} of the interview.
#'
#' @examples
#' \dontrun{
#' suso_getAllHistoryInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
#'           )
#'
#' }
#'
#' @return A data.table containing the history records for the interview.
#' @export
suso_getAllHistoryInterview <- function(server= suso_get_api_key("susoServer"),
                                        apiUser=suso_get_api_key("susoUser"),
                                        apiPass=suso_get_api_key("susoPass"),
                                        workspace = suso_get_api_key("workspace"),
                                        token = NULL,
                                        intID = "") {

  ## default workspace
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "interviews")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  # check int_id is uuid
  .checkUUIDFormat(intID)

  # append int_id to url
  url<-url |>
    req_url_path_append(intID, "history")

  tryCatch(
    {resp<-req_perform(url)},
    error = function(e) .http_error_handler(e, "ass")
  )

  # get the response data
  if(resp_has_body(resp)){
    # get body by content type
    if(resp_content_type(resp) == "application/json") {
      test_json<-resp_body_json(resp, simplifyVector = TRUE)
      # Export only records
      test_json<-data.table(test_json$Records)
      # Set date time to utc with lubridate
      if(nrow(test_json)>0) test_json[,Timestamp:=as_datetime(Timestamp)][]
      return(test_json)
    }
  } else {
    return(data.table(NULL))
  }
}


#' Get statistics for interview
#'
#' @description Fetch statistics for a specific interview, vectorized over interview id (int_id)
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param intID a single or multiple \emph{InterviewId}.
#'
#' @examples
#' \dontrun{
#' suso_get_stats_interview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
#'           )
#'
#' }
#'
#' @return A data.table containing statistics for the requested interview(s).
#' @export



suso_get_stats_interview<-function(server= suso_get_api_key("susoServer"),
                                   apiUser=suso_get_api_key("susoUser"),
                                   apiPass=suso_get_api_key("susoPass"),
                                   workspace = suso_get_api_key("workspace"),
                                   token = NULL,
                                   intID = "") {

  ## default workspace
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "interviews")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  # check int_id is uuid
  .checkUUIDFormat(intID[1])

  # singel request
  if(length(intID)==1){

    # append int_id to url
    url<-url |>
      req_url_path_append(intID, "stats")

    tryCatch(
      {resp<-req_perform(url)},
      error = function(e) .http_error_handler(e, "ass")
    )

    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = TRUE)
        # Export only records
        tj<-as.data.table(t(unlist(test_json)))
        names_col<-names(tj)[c(1:9,15:17)]
        for (col in names_col) set(tj, j=col, value=as.numeric(tj[[col]]))
        ## date conversion
        tj[,UpdatedAtUtc:=as_datetime(UpdatedAtUtc)]
        tj[,InterviewDuration:=as.POSIXct(InterviewDuration, format = "%H:%M:%OS")][]
        return(tj)
      }
    } else {
      return(data.table(NULL))
    }
  } else if(length(intID)>1) {

    requests<-.gen_lapply_with_progress(
      intID,
      .genrequests_w_path,
      "requests", "interviewers", workspace,
      url, intID, "stats"
    )


    responses <- httr2::req_perform_parallel(
      requests,
      max_active = getOption("suso.maxpar.req"),
      on_error = "continue"
    )


    # I. Response
    # I.1. Get faild responses
    failed <- responses |> httr2::resps_failures()
    # I.2. Get successful responses
    success <-responses |> httr2::resps_successes()
    # I.2.1. Check if there are any successful responses and stop if not
    rol<-"Requests"
    if(interactive() && length(failed)>0){
      cli::cli_div(theme = list(span.emph = list(color = "red")))
      cli::cli_alert_danger("
      {.emph Some requests failed!}
      Out of {length(requests)} {rol}, {length(failed)} failed.\n\n")
      cli::cli_end()
    } else if(length(success)==0) {
      cli::cli_abort(c("x" = "No successful requests!"))
    }
    # return(success)

    .transformresponses_tj<-function(i ,resp) {
      # i. Convert to json
      test_json <-resp[[i]] |>
        resp_body_json(simplifyVector = T, flatten = TRUE)

      # Export only records
      tj<-as.data.table(t(unlist(test_json)))
      names_col<-names(tj)[c(1:9,15:17)]
      for (col in names_col) set(tj, j=col, value=as.numeric(tj[[col]]))
      ## date conversion
      tj[,UpdatedAtUtc:=as_datetime(UpdatedAtUtc)]
      tj[,InterviewDuration:=as.POSIXct(InterviewDuration, format = "%H:%M:%OS")][]
      return(tj)
    }
    test_json<-.gen_lapply_with_progress(
      success,
      .transformresponses_tj,
      "responses", "interviewers", workspace,
      success
    )
    tj<-data.table::rbindlist(test_json, fill = T)
    return(tj)
  }

}



#' Reject interviews either as supervisor or as headquarter.
#'
#' @description Allows you to reject interviews in supervisor or headquarters role
#' as well as to provide a comment (i.e. reason) for the rejection.
#'
#'
#' @details  For details please see:
#' \url{https://docs.mysurvey.solutions/headquarters/interviews/survey-workflow/}
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param intID the \emph{InterviewId} of the interview.
#' @param new_uid if provided the interview will be rejected to a different user than the current one.
#' @param HQ if FALSE, reject as supervisor, if TRUE rejected as headquarters
#' @param comment comment which should be sent with the questionnaire
#'
#' @examples
#' \dontrun{
#' # reject the interview as supervisor
#' suso_patchRejectInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
#'           )
#' # reject the interview as headquarters
#' suso_patchRejectInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'           HQ = TRUE
#'           )
#' # reject the interview and provide a comment, so the interviewer knows about the problem
#' suso_patchRejectInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'           comment = "Too many errors, please check and re-submit!"
#'           )
#' # reject the interview to a different user
#' suso_patchRejectInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'           new_uid = "3b0c6e09-d606-4914-9e20-2abc048d5bea"
#'           )
#'
#' }
#'
#' @return A data.table containing the status of the rejection operation.
#' @export
#'
suso_patchRejectInterview <- function(server= suso_get_api_key("susoServer"),
                                      apiUser=suso_get_api_key("susoUser"),
                                      apiPass=suso_get_api_key("susoPass"),
                                      workspace = suso_get_api_key("workspace"),
                                      token = NULL,
                                      intID = "",
                                      new_uid = NULL,
                                      HQ = FALSE,
                                      comment = "Please check errors and re-submit!") {

  ## select reject
  reject<-ifelse(HQ, "hqreject", "reject")

  ## default workspace
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "interviews")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  # check int_id is uuid
  .checkUUIDFormat(intID[1])

  if(!is.null(new_uid)) .checkUUIDFormat(new_uid[1])


  # append int_id to url
  url<-url |>
    req_url_path_append(intID, reject) |>
    req_url_query(
      comment = comment,
      responsibleId = new_uid
    ) |>
    req_method("PATCH")


  tryCatch(
    {resp<-req_perform(url)},
    error = function(e) .http_error_handler(e, "ass")
  )

  test_json<-data.table::data.table(resp_status=200, intID=intID, new_uid=new_uid, description="success", HQ = HQ)

  return(test_json)


}



#' Approve interviews either as supervisor or as headquarter.
#'
#' @description Allows you to approve interviews in supervisor or headquarters role,
#' unapprove from headquarters status, as well as to provide a comment (i.e. reason).
#'
#'
#' @details  For details please see:
#' \url{https://docs.mysurvey.solutions/headquarters/interviews/survey-workflow/}
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param intID the \emph{InterviewId} of the interview.
#' @param HQ if FALSE, approve as supervisor, if TRUE approve as headquarters
#' @param hqunapprove if TRUE, unapprove from headquarters status (hqunapprove)
#' @param comment comment which should be sent with the questionnaire
#'
#' @examples
#' \dontrun{
#' # approve the interview as supervisor
#' suso_patchApproveInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
#'           )
#' # approve the interview as headquarters
#' suso_patchApproveInterview(
#'           workspace = "myworkspace",
#'           intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
#'           HQ = TRUE
#'           )
#' }
#'
#' @return A data.table containing the status of the approval operation.
#' @export
#'
suso_patchApproveInterview <- function(server= suso_get_api_key("susoServer"),
                                       apiUser=suso_get_api_key("susoUser"),
                                       apiPass=suso_get_api_key("susoPass"),
                                       workspace = suso_get_api_key("workspace"),
                                       token = NULL,
                                       intID = "",
                                       HQ = FALSE,
                                       hqunapprove = FALSE,
                                       comment = "Well done!") {
  ## select approve action
  approve <- if(hqunapprove) "hqunapprove" else if(HQ) "hqapprove" else "approve"

  ## default workspace
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # Base URL and path
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "interviews")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  # check int_id is uuid
  .checkUUIDFormat(intID[1])

  # append int_id to url
  url<-url |>
    req_url_path_append(intID, approve) |>
    req_url_query(
      comment = comment
    ) |>
    req_method("PATCH")


  tryCatch(
    {resp<-req_perform(url)},
    error = function(e) .http_error_handler(e, "ass")
  )

  test_json<-data.table::data.table(resp_status=200, intID=intID, description="success", action = approve)

  return(test_json)


}


#' Delete an interview
#'
#' Deletes an interview from the Survey Solutions server.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace name
#' @param token API token
#' @param intID InterviewId of the interview (GUID)
#'
#' @return A data.table indicating the deletion status.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_deleteInterview(intID = "11111111-2222-3333-4444-555555555555")
#' }
suso_deleteInterview <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 workspace = suso_get_api_key("workspace"),
                                 token = NULL,
                                 intID = "") {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)
  .checkUUIDFormat(intID[1])

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "interviews")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  url <- url |>
    req_url_path_append(intID) |>
    req_method("DELETE")

  tryCatch({
    resp <- req_perform(url)
    return(data.table::data.table(resp_status = 200, intID = intID, description = "deleted"))
  }, error = function(e) .http_error_handler(e, "ass"))
}


#' Download interview PDF transcript
#'
#' Downloads the PDF transcript of a completed interview.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace name
#' @param token API token
#' @param intID InterviewId (GUID)
#' @param path Destination file path for saving the PDF. If NULL, saves to tempdir.
#'
#' @return The file path where the PDF was saved.
#' @export
#'
#' @examples
#' \dontrun{
#' pdf_path <- suso_getInterviewPDF(intID = "11111111-2222-3333-4444-555555555555")
#' }
suso_getInterviewPDF <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 workspace = suso_get_api_key("workspace"),
                                 token = NULL,
                                 intID = "",
                                 path = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)
  .checkUUIDFormat(intID[1])

  if (is.null(path)) {
    path <- file.path(tempdir(), paste0("interview_", intID, ".pdf"))
  }

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "interviews")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  url <- url |> req_url_path_append(intID, "pdf")

  tryCatch({
    resp <- req_perform(url, path = path)
    return(path)
  }, error = function(e) .http_error_handler(e, "ass"))
}


#' Assign interview to interviewer or supervisor
#'
#' Reassigns an interview to a specified interviewer or supervisor.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace name
#' @param token API token
#' @param intID InterviewId (GUID)
#' @param userId User GUID of responsible person
#' @param userName Name of responsible person (optional)
#' @param supervisor If TRUE assigns to a supervisor, otherwise assigns to an interviewer
#'
#' @return A data.table indicating the assignment status.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_assignInterview(
#'   intID = "11111111-2222-3333-4444-555555555555",
#'   userName = "interviewer01"
#' )
#' }
suso_assignInterview <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 workspace = suso_get_api_key("workspace"),
                                 token = NULL,
                                 intID = "",
                                 userId = NULL,
                                 userName = NULL,
                                 supervisor = FALSE) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)
  .checkUUIDFormat(intID[1])
  if (is.null(userId) && is.null(userName)) {
    cli::cli_abort("Please provide either userId or userName.")
  }

  action <- ifelse(supervisor, "assignsupervisor", "assign")

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "interviews")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  body <- list()
  if (!is.null(userId)) body$UserId <- jsonlite::unbox(userId)
  if (!is.null(userName)) body$UserName <- jsonlite::unbox(userName)

  url <- url |>
    req_url_path_append(intID, action) |>
    req_method("PATCH") |>
    req_body_json(body)

  tryCatch({
    resp <- req_perform(url)
    return(data.table::data.table(resp_status = 200, intID = intID, action = action, description = "success"))
  }, error = function(e) .http_error_handler(e, "ass"))
}


#' Leave a comment on a question in an interview
#'
#' Leaves a comment on a question using either the questionId or the questionnaire variable name.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace name
#' @param token API token
#' @param intID InterviewId (GUID)
#' @param comment The comment text to leave
#' @param questionId The question GUID (optional if variable is provided)
#' @param variable Variable name of question (optional if questionId is provided)
#' @param rosterVector Integer vector specifying roster indices (e.g. c(0, 1))
#'
#' @return A data.table indicating the comment status.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_commentInterview(
#'   intID = "11111111-2222-3333-4444-555555555555",
#'   variable = "age",
#'   comment = "Please verify respondent age."
#' )
#' }
suso_commentInterview <- function(server = suso_get_api_key("susoServer"),
                                  apiUser = suso_get_api_key("susoUser"),
                                  apiPass = suso_get_api_key("susoPass"),
                                  workspace = suso_get_api_key("workspace"),
                                  token = NULL,
                                  intID = "",
                                  comment = "",
                                  questionId = NULL,
                                  variable = NULL,
                                  rosterVector = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)
  .checkUUIDFormat(intID[1])

  if (is.null(questionId) && is.null(variable)) {
    cli::cli_abort("Please provide either questionId or variable.")
  }

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "interviews")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "interviews")
  }

  if (!is.null(questionId)) {
    url <- url |>
      req_url_path_append(intID, "comment", questionId) |>
      req_url_query(comment = comment) |>
      req_method("POST")
  } else {
    url <- url |>
      req_url_path_append(intID, "comment-by-variable", variable) |>
      req_url_query(comment = comment) |>
      req_method("POST")
    if (!is.null(rosterVector)) {
      url <- url |> req_url_query(rosterVector = paste(rosterVector, collapse = ","))
    }
  }

  tryCatch({
    resp <- req_perform(url)
    return(data.table::data.table(resp_status = 200, intID = intID, comment = comment, description = "success"))
  }, error = function(e) .http_error_handler(e, "ass"))
}
