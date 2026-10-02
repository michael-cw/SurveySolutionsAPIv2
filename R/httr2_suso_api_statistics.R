#' Survey Solutions API call for Summary Tables
#'
#' Returns summary tables for individual questions from Survey Solutions statistics.
#' If no responses have been provided, an empty table will be returned.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID Questionnaire ID (GUID)
#' @param version Version of the questionnaire (numeric)
#' @param qQuest Question variable name or UUID
#' @param byTeam Logical, whether the table should contain reports by team (default: \code{TRUE})
#' @param exportType Report format: \code{"Csv"} (default) or \code{"Json"}
#'
#' @return A data.table containing the summary statistics for the question.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_get_stats(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1,
#'   qQuest = "age"
#' )
#' }
suso_get_stats <- function(server = suso_get_api_key("susoServer"),
                           apiUser = suso_get_api_key("susoUser"),
                           apiPass = suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           questID = NULL,
                           version = NULL,
                           qQuest = "",
                           byTeam = TRUE,
                           exportType = c("Csv", "Json")) {

  workspace <- .ws_default(ws = workspace)
  exportType <- match.arg(exportType)

  .check_basics(token, server, apiUser, apiPass)

  if (!is.null(questID) && nchar(questID) > 0) {
    .checkUUIDFormat(questID)
    questID <- stringr::str_remove_all(questID, "-")
  }

  if (!is.null(version) && (is.numeric(version) || nchar(as.character(version)) > 0)) {
    .checkNum(version)
  }

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "statistics")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "statistics")
  }

  url <- url |>
    httr2::req_url_query(
      QuestionnaireId = questID,
      Version = version,
      Question = qQuest,
      exportType = exportType,
      Pivot = "false",
      ExpandTeams = ifelse(byTeam, "true", "false")
    )

  resp <- tryCatch(
    httr2::req_perform(url),
    error = function(e) .http_error_handler(e, "ass")
  )

  if (httr2::resp_has_body(resp)) {
    c_type <- httr2::resp_content_type(resp)
    if (grepl("json", c_type, ignore.case = TRUE)) {
      test_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
      if (is.list(test_json) && "Answers" %in% names(test_json)) {
        return(data.table::as.data.table(test_json$Answers))
      }
      return(data.table::as.data.table(test_json))
    } else {
      # CSV / text response
      body_text <- httr2::resp_body_string(resp)
      if (nchar(trimws(body_text)) == 0) {
        return(data.table::data.table())
      }
      return(data.table::fread(text = body_text))
    }
  } else {
    return(data.table::data.table())
  }
}


#' Survey Solutions API call for questionnaires with statistics
#'
#' Retrieves the list of questionnaires that have statistics data on the server.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#'
#' @return A data.table listing questionnaires with statistics.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_getStatsQuestionnaires()
#' }
suso_getStatsQuestionnaires <- function(server = suso_get_api_key("susoServer"),
                                        apiUser = suso_get_api_key("susoUser"),
                                        apiPass = suso_get_api_key("susoPass"),
                                        workspace = suso_get_api_key("workspace"),
                                        token = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "statistics") |>
      httr2::req_url_path_append("questionnaires")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "statistics") |>
      httr2::req_url_path_append("questionnaires")
  }

  resp <- tryCatch(
    httr2::req_perform(url),
    error = function(e) .http_error_handler(e, "ass")
  )

  if (httr2::resp_has_body(resp)) {
    test_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
    return(data.table::as.data.table(test_json))
  } else {
    return(data.table::data.table())
  }
}


#' Survey Solutions API call for questions and responses from single questionnaire
#'
#' Returns all questions for a single questionnaire (ONLY if they contain responses). If you require all questions
#' from any questionnaire on the server, use \code{suso_getQuestDetails(..., operation.type = "structure")}.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID Questionnaire ID (GUID)
#' @param version Questionnaire version (numeric)
#'
#' @return A data.table listing questions with responses for the questionnaire.
#' @export
#'
#' @examples
#' \dontrun{
#' suso_getQuestionsQuestionnaire(
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1
#' )
#' }
suso_getQuestionsQuestionnaire <- function(server = suso_get_api_key("susoServer"),
                                           apiUser = suso_get_api_key("susoUser"),
                                           apiPass = suso_get_api_key("susoPass"),
                                           workspace = suso_get_api_key("workspace"),
                                           token = NULL,
                                           questID = NULL,
                                           version = NULL) {
  workspace <- .ws_default(ws = workspace)
  .check_basics(token, server, apiUser, apiPass)

  if (!is.null(token)) {
    url <- .baseurl_token(server, workspace, token, "statistics") |>
      httr2::req_url_path_append("questions")
  } else {
    url <- .baseurl_baseauth(server, workspace, apiUser, apiPass, "statistics") |>
      httr2::req_url_path_append("questions")
  }

  if (!is.null(questID)) {
    .checkUUIDFormat(questID)
    questID <- stringr::str_remove_all(questID, "-")
  }

  if (!is.null(version)) {
    .checkNum(version)
  }

  url <- url |>
    httr2::req_url_query(
      questionnaireId = questID,
      version = version
    )

  resp <- tryCatch(
    httr2::req_perform(url),
    error = function(e) .http_error_handler(e, "ass")
  )

  if (httr2::resp_has_body(resp)) {
    test_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
    return(data.table::as.data.table(test_json))
  } else {
    return(data.table::data.table())
  }
}
