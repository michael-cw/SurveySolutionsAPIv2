#' Create, update or delete a calendar event
#'
#' Create, update or delete a calendar event for one or several assignments or interviews.
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and
#' \emph{apiPass} will be ignored
#' @param AssId numeric vector of assignment id(s)
#' @param intID UUID vector of interview id(s)
#' @param comment a comment string
#' @param startDate new start date, format must be: \code{2024-01-16}
#' @param startTime new start date, format must be: \code{01:41:14}
#' @param startTZ time zone of the tablet device, use \code{\link[base]{OlsonNames}}
#' @param publicKey UUID vector of calender event id(s)
#'
#' @details
#' This function creates a calendar event either for one or several assignments or one or
#' several interviews. Either one of \code{AssID} or \code{intID} must not be NULL. If
#' \code{length(AssID)} or \code{length(AssID)} is greater 1, then \code{startDate},
#' \code{startTime} and \code{startTZ} must either be each of length 1 (same event for
#' all) or of the same length, allowing for multiple events with different times.
#'
#' @return a data.table with the created event(s).
#'
#' @examplesIf suso_PwCheck()==200
#' # add single calendar event to assignment
#' calEvass<-suso_createCALEV(AssId = 268,
#'                            startDate = "2024-01-17",
#'                            startTime = "10:40:00")
#'
#' # update single event
#' calEvup<-suso_updateCALEV(publicKey = calEvass$publicKey[1],
#'                          startDate = "2024-01-18",
#'                         startTime = "10:40:00")
#'
#' # delete single event
#' calEvDel<-suso_delCALEV(publicKey = calEvup$publicKey[1])
#'
#'
#' # add calendar event to multiple assignments
#' calEvass<-suso_createCALEV(AssId = 55:60,
#'                            startDate = "2024-01-18",
#'                            startTime = "11:40:00")
#' # delete multiple calendar events
#' calEvDel<-suso_delCALEV(publicKey = calEvass$publicKey)
#'
#'
#' @name calendarevent
NULL


#' @describeIn calendarevent add a calendar event
#' @export

suso_createCALEV <- function(server= suso_get_api_key("susoServer"),
                             apiUser=suso_get_api_key("susoUser"),
                             apiPass=suso_get_api_key("susoPass"),
                             workspace = suso_get_api_key("workspace"),
                             token = NULL,
                             intID = NULL,
                             AssId = NULL,
                             comment = NULL,
                             startDate = NULL,
                             startTime = NULL,
                             startTZ = "UTC") {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check dates & TZ
  # check from_date if provided
  if(is.null(startDate) | is.null(startTime) | is.null(startTZ)){
    cli::cli_abort(c(
      "x" = "You have to provide a date, a time and a valid time zone to create a calendar event"
    ))
  } else {
    .checkDate(startDate)
    .checkTimeZone(startTZ)
    .checkTime(startTime)
  }

  # create date time
  startDateTime <- .genDateTimeCheckNow(startDate, startTime, startTZ)



  if(!is.null(AssId)){
    # check ass id
    .checkNum(AssId[1])

    # SINGLE ASSIGNMENT
    if(length(AssId)==1){
      result<-.create_cal_event(
        server = server,
        workspace = workspace,
        apiUser = apiUser,
        apiPass = apiPass,
        AssId = AssId,
        comment = comment,
        startDateTime = startDateTime,
        startTZ = startTZ
      )
    } else if(length(AssId)>1) {
      # multiple assignments

      result<-sapply(seq_along(AssId),
                     function(x) {
                       .create_cal_event(
                         server = server,
                         workspace = workspace,
                         apiUser = apiUser,
                         apiPass = apiPass,
                         AssId = AssId[x],
                         comment = comment,
                         startDateTime = startDateTime,
                         startTZ = startTZ)},
                     USE.NAMES = FALSE, simplify = FALSE)

      result<-data.table::rbindlist(result, fill = TRUE)
    }
  } else if(!is.null(intID)){
    # check interview uuid
    .checkUUIDFormat(intID[1])

    # SINGLE INTERVIEW
    if(length(intID)==1) {
      result<-.create_cal_event(
        server = server,
        workspace = workspace,
        apiUser = apiUser,
        apiPass = apiPass,
        intID = intID,
        comment = comment,
        startDateTime = startDateTime,
        startTZ = startTZ
      )
    }  else if(length(intID)>1) {
      # multiple assignments
      result<-sapply(seq_along(intID),
                     function(x) {
                       .create_cal_event(
                         server = server,
                         workspace = workspace,
                         apiUser = apiUser,
                         apiPass = apiPass,
                         intID = intID[x],
                         comment = comment,
                         startDateTime = startDateTime,
                         startTZ = startTZ)},
                     USE.NAMES = FALSE, simplify = FALSE)

      result<-data.table::rbindlist(result, fill = TRUE)

    }
  } else {
    cli::cli_abort(c("x" = "Please provide either assignment id(s) or interview id(s)."))
  }


  # transform dates
  if(nrow(result)>0) result<-.transform_datetime(result)
  return(result)
}


#' @describeIn calendarevent update a calendar event
#' @export

suso_updateCALEV <- function(server= suso_get_api_key("susoServer"),
                             apiUser=suso_get_api_key("susoUser"),
                             apiPass=suso_get_api_key("susoPass"),
                             workspace = suso_get_api_key("workspace"),
                             token = NULL,
                             publicKey = NULL,
                             comment = NULL,
                             startDate = NULL,
                             startTime = NULL,
                             startTZ = "UTC") {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check dates & TZ
  # check from_date if provided
  if(is.null(startDate) | is.null(startTime) | is.null(startTZ)){
    cli::cli_abort(c(
      "x" = "You have to provide a date, a time and a valid time zone to create a calendar event"
    ))
  } else {
    .checkDate(startDate)
    .checkTimeZone(startTZ)
    .checkTime(startTime)
  }

  # create date time
  startDateTime <- .genDateTimeCheckNow(startDate, startTime, startTZ)



  if(!is.null(publicKey)){
    # check interview uuid
    .checkUUIDFormat(publicKey[1])

    result<-susographql::suso_gql_updatecalendarevent(
      endpoint = paste0(server, "graphql"),
      workspace = workspace,
      user = apiUser,
      password = apiPass,
      publicKey  = publicKey,
      comment = comment,
      newStart = startDateTime,
      startTimezone = startTZ
    )
    result<-data.table(t(unlist(result$updateCalendarEvent)))
  } else {
    cli::cli_abort(c("x" = "Please provide a calendar event public key."))
  }


  # transform dates
  if(nrow(result)>0) result<-.transform_datetime(result)
  return(result)
}

#' @describeIn calendarevent delete a calendar event
#' @export

suso_delCALEV <- function(server= suso_get_api_key("susoServer"),
                             apiUser=suso_get_api_key("susoUser"),
                             apiPass=suso_get_api_key("susoPass"),
                             workspace = suso_get_api_key("workspace"),
                             token = NULL,
                             publicKey = NULL) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  if(!is.null(publicKey)){
    # check interview uuid
    .checkUUIDFormat(publicKey[1])
    # single key
    if(length(publicKey) == 1) {
      result<-susographql::suso_gql_deletecalendarevent(
        endpoint = paste0(server, "graphql"),
        workspace = workspace,
        user = apiUser,
        password = apiPass,
        publicKey  = publicKey
      )
      result<-data.table(t(unlist(result$deleteCalendarEvent)))
    } else if(length(publicKey)>1) {
      delmulti<-function(x) {
        result<-susographql::suso_gql_deletecalendarevent(
          endpoint = paste0(server, "graphql"),
          workspace = workspace,
          user = apiUser,
          password = apiPass,
          publicKey  = publicKey[x]
        )
        result<-data.table(t(unlist(result$deleteCalendarEvent)))
      }
      result<-sapply(seq_along(publicKey),
                     delmulti,
                     USE.NAMES = FALSE, simplify = FALSE)
      result<-data.table::rbindlist(result, fill = TRUE)
    }
  } else {
    cli::cli_abort(c("x" = "Please provide a calendar event public key."))
  }


  # transform dates
  if(nrow(result)>0) result<-.transform_datetime(result)
  return(result)
}


#' helper function for calendar events create
#'
#'
#' @noRd
#' @keywords internal calendarevent
#'
.create_cal_event<-function(...) {
  args<-rlang::list2(...)
  if(!is.null(args$AssId)){
    result<-susographql::suso_gql_addassignmentcalendarevent(
      endpoint = paste0(args$server, "graphql"),
      workspace = args$workspace,
      user = args$apiUser,
      password = args$apiPass,
      assignmentId = args$AssId,
      comment = args$comment,
      newStart = args$startDateTime,
      startTimezone = args$startTZ
    )
    result<-data.table(t(unlist(result$addAssignmentCalendarEvent)))
  }

  if(!is.null(args$intID)) {
    result<-susographql::suso_gql_addinterviewcalendarevent(
      endpoint = paste0(args$server, "graphql"),
      workspace = args$workspace,
      user = args$apiUser,
      password = args$apiPass,
      interviewId = args$intID,
      comment = args$comment,
      newStart = args$startDateTime,
      startTimezone = args$startTZ
    )
    result<-data.table(t(unlist(result$addInterviewCalendarEvent)))
  }
  return(result)
}


