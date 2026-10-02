#' Survey Solutions API call for questionnaire
#'
#'
#' \code{suso_getQuestDetails} implements all Questionnaire related API commands. It allows for different operation types,
#' see details bellow for further clarification.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{usr} and \emph{pass} will be ignored
#' @param questID \emph{QuestionnaireId} for which details should be exported
#' @param version questionnaire version
#' @param operation.type if \emph{list} is specified a list of all questionnaires on the server. If
#' \emph{statuses} a vector of all questionnaire statuses. If \emph{structure} is specified, it returns a list
#' containing all questions, rosters etc. of the specific questionnaire, as well as all validations.
#' If \emph{interviews} is specified, all interviews for a specific questionnaire. See details bellow.
#' @param include_raw logical; if \code{TRUE}, retains the raw JSON list column (\code{..JSON}) in the question table when \code{operation.type = "structure"}. Default is \code{FALSE} for clean, flat data tables.
#' @param AssId Assignment ID (only required if operations.type is\emph{interviews})
#' @param InterviewKey Interview key (only required if operations.type is\emph{interviews})
#' @param errorsCount desired number of errors (only required if operations.type is\emph{interviews})
#' @param errosCountFilter relational type for error counts, either smaller equal, equal or greater equal than
#' the number specified in \code{errorsCount}, if not supplied defaults to lower equal than  \emph{interviews})
#' (only required if operations.type is\emph{interviews})
#' @param interviewMode Interview mode (CAWI or CAPI) (only required if operations.type is\emph{interviews})
#' @param notAnsweredCount number of unanswered questions (only required if operations.type is\emph{interviews})
#' @param notAnsweredCountFilter relational type for unanswered question counts, either smaller equal, equal or greater equal than
#' the number specified in \code{notAnsweredCount}, if not supplied defaults to lower equal than  \emph{interviews})
#' (only required if operations.type is\emph{interviews})
#' @param QuestionnaireVariable the variable for the questionnaire (only required if operations.type is\emph{interviews})
#' @param ResponsibleName Name of the person responsible (only required if operations.type is\emph{interviews})
#' @param responsibleRole Role of the person responsible (only required if operations.type is\emph{interviews})
#' @param workStatus of the interview (only required if operations.type is\emph{interviews})
#' @param supervisorName Name of the supervisor of the responsible user (only required if operations.type is\emph{interviews})
#'
#'
#' @details
#'
#' If list is selected, then list of questionnaires is returned.
#'
#' If statuses is selected, a list of all available questionnaire statuses is returned (deprecated).
#'
#' In case structure is chosen the return value is a list with four data.table elements:
#' \itemize{
#'   \item List element \emph{q} contains all questions, rosters etc. with full metadata.
#'   \item List element \emph{val} contains all validations.
#'   \item List element \emph{v} is an alias for \emph{val} for backward compatibility.
#'   \item List element \emph{answers} contains categorical answer options, codes, and linked questions.
#' }
#' In this way it is straightforward to use the return value for questionnaire manuals and the likes.
#'
#' In case interviews is selected, a list of all interviews for the specific questionnaire is returned.
#'
#' @return Depending on \code{operation.type}:
#' \describe{
#'   \item{list}{A data.table listing all questionnaires on the server.}
#'   \item{statuses}{A character vector of questionnaire statuses.}
#'   \item{structure}{A list with four data.tables: \code{q} (questions/rosters metadata), \code{val} (validations), \code{v} (alias for \code{val}), and \code{answers} (categorical answer options and codes).}
#'   \item{interviews}{A data.table listing interviews for the specified questionnaire.}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' # List all questionnaires on the server
#' q_list <- suso_getQuestDetails(operation.type = "list")
#'
#' # Get questionnaire structure (questions, validations, answers)
#' q_struct <- suso_getQuestDetails(
#'   questID = q_list$QuestionnaireId[1],
#'   version = q_list$Version[1],
#'   operation.type = "structure"
#' )
#' }
#'
suso_getQuestDetails <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 workspace = suso_get_api_key("workspace"),
                                 token = NULL,
                                 questID = NULL, version = NULL,
                                 operation.type = c("list", "statuses", "structure", "interviews"),
                                 include_raw = FALSE,
                                 AssId = NULL,
                                 InterviewKey = NULL,
                                 errorsCount = NULL, errosCountFilter = c("lower", "higher", "equal"),
                                 interviewMode = c("CAPI", "CAWI"),
                                 notAnsweredCount = NULL, notAnsweredCountFilter = c("lower", "higher", "equal"),
                                 QuestionnaireVariable = NULL,
                                 ResponsibleName = NULL,
                                 responsibleRole = c("INTERVIEWER", "SUPERVISOR"),
                                 workStatus=c("All", "SupervisorAssigned", "InterviewerAssigned",
                                              "RejectedBySupervisor", "Completed",
                                              "ApprovedBySupervisor",
                                              "RejectedByHeadquarters",
                                              "ApprovedByHeadquarters"),
                                 supervisorName = NULL) {
  
  take <- 100
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
  operation.type <- match.arg(operation.type)
  
  # define endpoint
  endpoint <- paste0(server, "graphql")
  
  if (operation.type == "list") {
    #uses susographql package
    
    # first request
    quest1<-susographql::suso_gql_questionnaires(
      endpoint = endpoint,
      workspace = workspace,
      user = apiUser,
      password = apiPass,
      id = questID,
      version = version,
      take = take,
      skip = 0
    )
    
    # check if there are more questionnaires than 100
    tot<-quest1$questionnaires$totalCount
    
    # get first 100
    quest1<-data.table::data.table(quest1$questionnaires$nodes)
    # get the rest
    if(tot>take){
      # if yes, then get the rest in a loop
      rest<-tot-take
      steps<-ceiling(rest/take)
      quest2<-list()
      for(i in 1:steps){
        quest2[[i]]<-susographql::suso_gql_questionnaires(
          endpoint = endpoint,
          workspace = workspace,
          user = apiUser,
          password = apiPass,
          id = questID,
          version = version,
          take = take,
          skip = i*take
        )$questionnaires$nodes
      }
      
      # bind all together
      quest2<-data.table::rbindlist(quest2)
      quest1<-data.table::rbindlist(list(quest1,quest2))
      
    }
    
    # if empty return
    if(nrow(quest1)==0) {
      return(data.table::data.table(NULL))
    } else {
      # Modify names to match REST API
      data.table::setnames(quest1,
                           old = c("questionnaireId", "variable", "version", "id", "title"),
                           new = c("QuestionnaireId", "Variable", "Version", "QuestionnaireIdentity", "Title")
      )
      
      # Set date time to utc with lubridate
      # !! ATTENTION: susographql does currently not return the data, check and update
      # quest1[,LastEntryDate:=as_datetime(LastEntryDate)][]
      
      # add translation ids (if any)
      if(!is.null(quest1$translations) && !(all(sapply(quest1[["translations"]], function(x) length(x) == 0)))){
        quest1<-.unnest_df_in_dt(quest1, col=translations, id = (names(quest1)[names(quest1)!="translations"]), "name", "id")
        quest1<-quest1[,translations:=NULL]
      } else if (!is.null(quest1$translations)) {
        # if none available delete
        quest1<-quest1[,translations:=NULL]
      }
      
      # return
      return(quest1[])
    }
  } else if (operation.type == "statuses") {
    # only for consistency reason, api is deprecated
    
    test_json<-jsonlite::fromJSON('[
                                      "Restored",
                                      "Created",
                                      "SupervisorAssigned",
                                      "InterviewerAssigned",
                                      "RejectedBySupervisor",
                                      "ReadyForInterview",
                                      "SentToCapi",
                                      "Restarted",
                                      "Completed",
                                      "ApprovedBySupervisor",
                                      "RejectedByHeadquarters",
                                      "ApprovedByHeadquarters",
                                      "Deleted"
                                    ]'
    )
    return(test_json)
    
  } else if(operation.type == "structure") {
    if (is.null(questID) | is.null(version)){
      withr::with_options(
        list(rlang_backtrace_on_error = "none"),
        cli::cli_abort(c("x" = "questID and/or version missing."), call = NULL)
      )
    }
    
    # Build the URL, first for token, then for base auth
    if(!is.null(token)){
      url<-.baseurl_token(server, workspace, token, "questionnaires", version = "v1")
    } else {
      url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "questionnaires", version = "v1")
    }
    
    url<-req_url_path_append(url, questID, version, "document")
    
    # get argument for class
    args<-.getargsforclass(workspace = workspace)
    
    # check if export file with same parameters is is available
    aJsonFile<-tempfile(fileext = ".json")
    tryCatch(
      { resp<-url |>
        httr2::req_perform(
          path = aJsonFile
        )
      
      # get the response data
      if(resp_has_body(resp)){
        # get body by content type
        if(resp_content_type(resp) == "application/json") {
          test_json <- .suso_transform_fullValid_q(aJsonFile, include_raw = include_raw)
          
          # Variable Format
          if(nrow(test_json$q)>0 && "LastEntryDate" %in% names(test_json$q)) {
            test_json$q[,LastEntryDate:=lubridate::as_datetime(LastEntryDate)][]
          }
        }
      } else {
        # return empty if no body
        test_json<-list(
          q = data.table::data.table(),
          val = data.table::data.table(),
          v = data.table::data.table(),
          answers = data.table::data.table()
        )
      }
      },
      error = function(e) .http_error_handler(e, "ass")
    )
    
    return(test_json)
    
  } else if(operation.type == "interviews") {
    # use graphql
    # prepare inputs
    # errors count
    if(!is.null(errorsCount)){
      .checkNum(errorsCount)
      op<-rlang::arg_match(errosCountFilter)
      errorsCount<-switch(op,
                          lower = susographql::lte(errorsCount),
                          equal = susographql::eq(errorsCount),
                          upper = susographql::gte(errorsCount)
      )
    }
    
    # not answered count
    if(!is.null(notAnsweredCount)){
      .checkNum(notAnsweredCount)
      op<-rlang::arg_match(notAnsweredCountFilter)
      notAnsweredCount<-switch(op,
                               lower = susographql::lte(notAnsweredCount),
                               equal = susographql::eq(notAnsweredCount),
                               upper = susographql::gte(notAnsweredCount)
      )
    }
    
    # workstatus
    if(!is.null(workStatus)) {
      workStatus<-rlang::arg_match(workStatus)
      workStatus<-toupper(workStatus)
      # NULL if all
      if(workStatus=="ALL") workStatus<-NULL
    }
    
    # int key
    if(!is.null(InterviewKey)) {
      .checkIntKeyformat(InterviewKey)
      
    }
    
    # interview mode
    if(!is.null(interviewMode)) {
      interviewMode<-rlang::arg_match(interviewMode)
    }
    
    # assid
    if(!is.null(AssId)) .checkNum(AssId)
    
    
    
    # first request
    quest1<-susographql::suso_gql_interviews(
      endpoint = endpoint,
      workspace = workspace,
      user = apiUser,
      password = apiPass,
      questionnaireId = questID,
      questionnaireVersion = susographql::eq(version),
      errorsCount = errorsCount,
      notAnsweredCount = notAnsweredCount,
      status = workStatus,
      clientKey = InterviewKey,
      supervisorName = supervisorName,
      responsibleName = ResponsibleName,
      interviewMode = interviewMode,
      assignmentId = AssId,
      take = take,
      skip = 0
    )
    
    # check if there are more questionnaires than 100
    tot<-quest1$interviews$totalCount
    
    # get first 100
    quest1<-data.table::data.table(quest1$interviews$nodes)
    
    if(tot>take){
      # if yes, then get the rest in a loop
      rest<-tot-take
      steps<-ceiling(rest/take)
      quest2<-list()
      for(i in 1:steps){
        quest2[[i]]<-data.table::data.table(
          susographql::suso_gql_interviews(
            endpoint = endpoint,
            workspace = workspace,
            user = apiUser,
            password = apiPass,
            questionnaireId = questID,
            questionnaireVersion = susographql::eq(version),
            errorsCount = errorsCount,
            notAnsweredCount = notAnsweredCount,
            status = workStatus,
            clientKey = InterviewKey,
            supervisorName = supervisorName,
            responsibleName = ResponsibleName,
            interviewMode = interviewMode,
            assignmentId = AssId,
            take = take,
            skip = i*take
          )$interviews$nodes
        )
      }
      
      # bind all together
      quest2<-data.table::rbindlist(quest2, fill = T)
      quest1<-data.table::rbindlist(list(quest1,quest2), fill = T)
      
    }
    
    # if empty return
    if(nrow(quest1)==0) {
      return(data.table::data.table(NULL))
    } else {
      # Modify names to match REST API
      data.table::setnames(quest1,
                           old = c("questionnaireId", "questionnaireVariable", "questionnaireVersion", "assignmentId", "responsibleId",
                                   "responsibleName", "status", "id", "identifyingData", "errorsCount", "updateDateUtc",
                                   "receivedByInterviewerAtUtc", "clientKey"),
                           new = c("QuestionnaireId", "QuestionnaireVariable", "QuestionnaireVersion", "AssignmentId", "ResponsibleId",
                                   "ResponsibleName", "Status", "InterviewId", "FeaturedQuestions", "ErrorsCount", "LastEntryDate",
                                   "ReceivedByDeviceAtUtc", "InterviewKey"), skip_absent = T
      )
      quest1[,LastEntryDate:=lubridate::as_datetime(LastEntryDate)]
      quest1[,ReceivedByDeviceAtUtc:=lubridate::as_datetime(ReceivedByDeviceAtUtc)][]
    }
    return(quest1)
  }
  
  ##############################################
}


#' Survey Solutions API call for questionnaire criticality level setting
#'
#' Gets or sets the criticality level setting for a specific questionnaire.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID Questionnaire ID (GUID)
#' @param version Questionnaire version (numeric)
#' @param level Criticality level to set: \code{"Unknown"}, \code{"Ignore"}, \code{"Warn"}, or \code{"Block"}.
#'   If \code{NULL} (default), gets the current criticality level setting.
#'
#' @return When \code{level = NULL}, returns the current criticality level setting.
#'   When \code{level} is provided, returns \code{TRUE} invisibly upon successful update.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get current criticality level
#' suso_questCriticalityLevel(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1
#' )
#' # Set criticality level to Warn
#' suso_questCriticalityLevel(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1,
#'   level = "Warn"
#' )
#' }
suso_questCriticalityLevel <- function(server = suso_get_api_key("susoServer"),
                                       apiUser = suso_get_api_key("susoUser"),
                                       apiPass = suso_get_api_key("susoPass"),
                                       workspace = suso_get_api_key("workspace"),
                                       token = NULL,
                                       questID = NULL,
                                       version = NULL,
                                       level = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)

  if (is.null(questID) || is.null(version)) {
    cli::cli_abort(c("x" = "Both 'questID' and 'version' must be provided."))
  }
  .checkUUIDFormat(questID)
  .checkNum(version)

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "questionnaires", version = "v1")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "questionnaires", version = "v1")
  }
  url <- httr2::req_url_path_append(url, questID, version, "criticalityLevel")

  if (is.null(level)) {
    url <- httr2::req_method(url, "GET")
    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "ass")
    )
    if (httr2::resp_has_body(resp)) {
      return(httr2::resp_body_json(resp, simplifyVector = TRUE))
    }
    return(NULL)
  } else {
    level <- match.arg(level, c("Unknown", "Ignore", "Warn", "Block"))
    url <- url |>
      httr2::req_method("POST") |>
      httr2::req_body_json(list(CriticalityLevel = level))

    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "ass")
    )
    if (httr2::resp_status(resp) == 204) {
      if (interactive()) {
        cli::cli_alert_success("Criticality level updated to {level}.")
      }
      return(invisible(TRUE))
    }
    return(invisible(FALSE))
  }
}


#' Survey Solutions API call for questionnaire audio recording setting
#'
#' Gets or sets the audio recording setting for a specific questionnaire.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID Questionnaire ID (GUID)
#' @param version Questionnaire version (numeric)
#' @param enabled Logical. If provided (\code{TRUE} or \code{FALSE}), updates the audio recording setting.
#'   If \code{NULL} (default), retrieves the current audio recording setting.
#'
#' @return When \code{enabled = NULL}, returns a list with \code{Enabled} (logical) and \code{AudioAuditScope} (character vector).
#'   When \code{enabled} is provided, returns \code{TRUE} invisibly upon successful update.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get current audio recording setting
#' suso_questRecordAudio(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1
#' )
#' # Enable audio recording
#' suso_questRecordAudio(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1,
#'   enabled = TRUE
#' )
#' }
suso_questRecordAudio <- function(server = suso_get_api_key("susoServer"),
                                  apiUser = suso_get_api_key("susoUser"),
                                  apiPass = suso_get_api_key("susoPass"),
                                  workspace = suso_get_api_key("workspace"),
                                  token = NULL,
                                  questID = NULL,
                                  version = NULL,
                                  enabled = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)

  if (is.null(questID) || is.null(version)) {
    cli::cli_abort(c("x" = "Both 'questID' and 'version' must be provided."))
  }
  .checkUUIDFormat(questID)
  .checkNum(version)

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "questionnaires", version = "v1")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "questionnaires", version = "v1")
  }
  url <- httr2::req_url_path_append(url, questID, version, "recordAudio")

  if (is.null(enabled)) {
    url <- httr2::req_method(url, "GET")
    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "ass")
    )
    if (httr2::resp_has_body(resp)) {
      return(httr2::resp_body_json(resp, simplifyVector = TRUE))
    }
    return(NULL)
  } else {
    if (!is.logical(enabled) || length(enabled) != 1) {
      cli::cli_abort(c("x" = "'enabled' must be a single logical value (TRUE or FALSE)."))
    }
    url <- url |>
      httr2::req_method("POST") |>
      httr2::req_body_json(list(Enabled = enabled))

    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "ass")
    )
    if (httr2::resp_status(resp) == 204) {
      if (interactive()) {
        cli::cli_alert_success("Audio recording setting updated to {enabled}.")
      }
      return(invisible(TRUE))
    }
    return(invisible(FALSE))
  }
}
