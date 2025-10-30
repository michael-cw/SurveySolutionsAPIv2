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
#' In case structure is chosen the return value is a list with two data.table elements:
#' \itemize{
#'   \item List element \emph{q} contains all questions, rosters etc.
#'   \item List element \emph{val} contains all validations
#' }
#' In this way it is straightforward to use the returen value for questionnaire manuals and the likes.
#'
#' In case interviews is selected, a list of all interviews for the specific questionnaire is returned.
#'
#' @export
#'
#'

suso_getQuestDetails <- function(server = suso_get_api_key("susoServer"),
                                 apiUser = suso_get_api_key("susoUser"),
                                 apiPass = suso_get_api_key("susoPass"),
                                 workspace = suso_get_api_key("workspace"),
                                 token = NULL,
                                 questID = NULL, version = NULL,
                                 operation.type = c("list", "statuses", "structure", "interviews"),
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
          test_json <- tidyjson::read_json(aJsonFile)
          test_json <- .suso_transform_fullValid_q(test_json)
          
          # Variable Format
          if(nrow(test_json$q)>0) {
            test_json$q[,LastEntryDate:=lubridate::as_datetime(LastEntryDate)][]
          }
        }
      } else {
        # return empty if no body
        test_json<-list(q = NULL, v = NULL)
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
