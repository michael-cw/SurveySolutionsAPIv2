#' Survey Solutions API call for assignment list
#'
#'
#' \code{suso_get_assignments} calls the Survey Solutions assignment API
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param workspace If workspace name is provide requests are made regarding this specific workspace
#' @param questID only assignments for \emph{QuestionnaireId} are returned,
#' requires \code{version} being not NULL
#' @param version version of the questionnaire, only required with \code{questID}
#' @param AssId if NULL a list of all assignments on the server, if not NULL
#' the assignment details for a specific assignment ID
#' @param responsibleID the ID of the responsible user (Supervisor or Interviewer).
#' Retrieves all assignments for this user.
#' @param ShowArchive if TRUE, only archived assignments are included in the list
#' @param order.by determines the column by which the assignment list should be ordered, one of
#' \emph{Id}, \emph{ResponsibleName}, \emph{InterviewsCount}, \emph{Quantity}, \emph{UpdatedAtUtc}, \emph{CreatedAtUtc},
#' followed by ordering direction "ASC" or "DESC", e.g. "Id DESC" or "CreatedAtUtc ASC"
#' @param operations.type specifies the desired operation, one of assignmentQuantitySettings, history, or recordAudio,
#' if specified, requires also \emph{AssId} to be specified.
#'
#' @param searchBy Filter result by custom search query
#' @param supervisorId Filter assignments by supervisor ID
#' @param status Filter assignments by status (e.g. NotAssigned, Assigned, Closed, Archived, Deleted, Completed)
#' @param start start index for history query (only with operations.type = "history")
#' @param length page length for history query (only with operations.type = "history")
#'
#' @return Returns an S3 object of assignmentClass. If you select any of the operations types, then no data.frame is returned,
#' the data.table will be NULL, however any information returned from the API can be retrieved by using the \code{getinfo()}
#' function with the corresponding arguments.
#'
#' @examples
#' \dontrun{
#'
#' # get all assignment for specific workspace
#' asslist<-suso_get_assignments(
#'                    workspace = "myworkspace"
#'                    )
#' # get all assignment for specific responsible
#' asslist<-suso_get_assignments(
#'                    workspace = "myworkspace",
#'                    responsibleID = "a67d2b82-bf28-40cf-bd1a-7901225c0885"
#'                    )
#' # get the overall count
#' getinfo(asslist, "totalcount")
#'
#' #get all single assignment details
#' asslist<-suso_get_assignments(
#'                    workspace = "myworkspace",
#'                    AssId = 1
#'                    )
#' # retrieve the uid of the person responsible
#' getinfo(asslist, "responsibleid")
#'
#' # get the status of the quantitysettings
#' asslist<-suso_get_assignments(
#'                    workspace = "myworkspace",
#'                    AssId = 1,
#'                    operations.type = "assignmentQuantitySettings")
#' asslist
#' Null data.table (0 rows and 0 cols)
#'
#' getinfo(asslist, "canchangequantity")
#' [1] TRUE
#' }
#'
#'
#' @export
#'

suso_get_assignments<-function(server = suso_get_api_key("susoServer"),
                               apiUser = suso_get_api_key("susoUser"),
                               apiPass = suso_get_api_key("susoPass"),
                               token = NULL,
                               workspace = suso_get_api_key("workspace"),
                               questID = NULL,
                               AssId=NULL,
                               version= NULL,
                               responsibleID = NULL,
                               supervisorId = NULL,
                               searchBy = NULL,
                               status = NULL,
                               start = NULL,
                               length = NULL,
                               ShowArchive = FALSE,
                               order.by=c("Id ASC", "Id DESC", "ResponsibleName DESC", "ResponsibleName ASC",
                                          "InterviewsCount DESC", "InterviewsCount ASC", "Quantity DESC",
                                          "Quantity ASC", "UpdatedAtUtc DESC", "UpdatedAtUtc ASC",
                                          "CreatedAtUtc DESC", "CreatedAtUtc ASC"),
                               operations.type = c("assignmentQuantitySettings",
                                                   "history",
                                                   "recordAudio")) {


  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check for valid operations.type if provided
  # if not return empty character vector
  if(length(operations.type) == 1) {
    operations.type<-match.arg(operations.type)
  } else {
    operations.type<-character(0)
  }

  # check for valid order.by
  order.by<-match.arg(order.by)

  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "assignments")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "assignments")
  }

  # get argument for class
  args<-.getargsforclass(workspace = workspace)

  # A. get all assignments (with parameters)
  if(length(operations.type)==0 && is.null(AssId)){
    # add order.by
    url<-.addQuery(url, Order = order.by)

    # add questID if not null
    if(!is.null(questID)){
      # check for valid version
      if(is.null(version)){
        cli::cli_abort(c("x" = "You have provided a Questionnaire ID, please also provide a version number."))
      } else {
        .checkUUIDFormat(questID)
        .checkNum(x = version)
        QID<-paste0(questID, "$", version)
        url<-.addQuery(url, QuestionnaireId = QID)
      }
    }
    # add responsibleID if not null
    if(!is.null(responsibleID)){
      url<-.addQuery(url, Responsible = responsibleID)
    }

    # add supervisorId if not null
    if(!is.null(supervisorId)){
      url<-.addQuery(url, SupervisorId = supervisorId)
    }

    # add searchBy if not null
    if(!is.null(searchBy)){
      url<-.addQuery(url, SearchBy = searchBy)
    }

    # add status if not null
    if(!is.null(status)){
      url<-.addQuery(url, Status = status)
    }

    # add ShowArchive if TRUE
    if(ShowArchive){
      url<-.addQuery(url, ShowArchive = TRUE)
    }

    # generate and execute first request with limit 100 & offset 0
    url<-.addQuery(url, Limit=100, offset=0)

    tryCatch(
      {resp<-req_perform(url)},
      error = function(e) .http_error_handler(e, "ass")
    )

    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = TRUE)
        full_data1<-data.table::data.table(test_json$Assignments, key = "Id")

        # get the total count
        tot<-test_json$TotalCount
      }
    }


    # if yes, then generate a list of urls with offset
    if(tot>100){
      # request generator, move to helpers?
      # .genrequests_w_offset<- function(i) {
      #   url<-url |>
      #     req_url_query(
      #       Limit = 100,
      #       offset = 100*i
      #     )
      #   return(url)
      # }
      # get the remaining items & create a list of requests
      rest<-tot-100
      loop.counter<-ceiling(rest/100)
      df<-1:loop.counter
      # if(interactive()){
      #   pgtext<-sprintf("Creating requests for assignments in workspace %s.", workspace)
      #   requests<-lapply(cli::cli_progress_along(df, pgtext), .genrequests_w_offset, url, lim = 100, off = 100, multi = T)
      # } else {
      #   requests <- lapply(seq_along(df), .genrequests_w_offset, url, lim = 100, off = 100, multi = T)
      # }

      # ATTENTION: PROGRESSBAR SEEMS NOT TO WORK IN THIS CONTEXT!!! CHECK!!!
      requests<-.gen_lapply_with_progress(
        1:loop.counter,
        .genrequests_w_offset,
        "requests", "assignments", workspace,
        url, lim = 100, off = 100, multi = T,
        call = rlang::caller_env()
      )


      # generate list of tempfiles used in path to write response (seems to be faster than using resp_body_json)
      tmpfiles <- tempfile(sprintf("suso_%d", df), tmpdir = tempdir(), fileext = ".json")
      # check if length of requests and tmpfiles is the same
      if(!(length(requests)==length(tmpfiles))) {
        cli::cli_abort("Length of requests and tmpfiles is not the same")
      }

      # execute requests in parallel !! move new pool settings to options
      responses <- httr2::req_perform_parallel(
        requests, paths = tmpfiles,
        max_active = getOption("suso.maxpar.req"),
        on_error = "return"
      )

      # !! what to do with failures? Mayb while loop--> WITH return there are
      # failures, but length of tmpfiles must be subset!
      if(length(requests) != length(responses)) {
        cli::cli_abort("Length of requests and responses is not the same")
      }

      # transform response from json tempfile takes 2.51 seconds
      full_data2<-.gen_lapply_with_progress(
        1:loop.counter,
        .transformresponses_jsonlite_iter,
        "responses", "assignments", workspace,
        tmpfiles, "Assignments",
        call = rlang::caller_env()
      )
      full_data2<-data.table::rbindlist(full_data2, fill = T)

      # remove tempfile
      unlink(tmpfiles)

      # With assignemtne class for later use
      test_json$Assignments<-data.table::rbindlist(list(full_data1, full_data2))
      test_json<-assignmentClass(test_json, args)
      # test_json<-data.table::rbindlist(list(full_data1, full_data2))
      # modify data types
      if(nrow(test_json>0)) {
        test_json[,CreatedAtUtc:=lubridate::as_datetime(CreatedAtUtc)][,UpdatedAtUtc:=lubridate::as_datetime(UpdatedAtUtc)]
        test_json[,ReceivedByTabletAtUtc:=lubridate::as_datetime(ReceivedByTabletAtUtc)][]
        return(test_json)
      } else {
        return(NULL)
      }
    } else {
      test_json$Assignments<-full_data1
      test_json<-assignmentClass(test_json, args)
      # modify data types
      if(nrow(test_json>0)) {
        test_json[,CreatedAtUtc:=lubridate::as_datetime(CreatedAtUtc)][,UpdatedAtUtc:=lubridate::as_datetime(UpdatedAtUtc)]
        test_json[,ReceivedByTabletAtUtc:=lubridate::as_datetime(ReceivedByTabletAtUtc)][]
        return(test_json)
      } else {
        # return empty assignmentClass object
        test_json$Assignments<-data.table::data.table()
        test_json<-assignmentClass(test_json, args)
        return(test_json)
      }
    }
  } else if(length(operations.type)==0 && !is.null(AssId)) {
    # B. get assignment details for a single assignment
    .checkNum(x = AssId)
    url<-req_url_path_append(url, AssId)
    tryCatch(
      { resp<-url |>
        httr2::req_perform()

      # get the response data
      if(resp_has_body(resp)){
        # get body by content type
        if(resp_content_type(resp) == "application/json") {
          test_json<-resp_body_json(resp, simplifyVector = TRUE)
          test_json<-assignmentClass(test_json, args)
          return(test_json)
        }
      }
      },
      error = function(e) {
        # return empty assignmentClass object
        test_json<-list()
        test_json$IdentifyingData<-data.table::data.table()
        test_json<-assignmentClass(test_json, args)
        return(test_json)
      }
    )
  } else {
    # Selected operations.type
    # Selected operations.type
    if(operations.type=="assignmentQuantitySettings") {
      # Change the quantity
      .checkNum(x = AssId)
      url<-req_url_path_append(url, AssId, "assignmentQuantitySettings")
      tryCatch(
        { resp<-url |>
          httr2::req_perform()

        # get the response data
        if(resp_has_body(resp)){
          # get body by content type
          if(resp_content_type(resp) == "application/json") {
            test_json<-resp_body_json(resp, simplifyVector = TRUE)
            test_json$Assignments<-data.table::data.table()
            test_json<-assignmentClass(test_json, args)
            return(test_json)
          }
        }
        },
        error = function(e) {
          # return empty assignmentClass object
          test_json<-list()
          test_json$IdentifyingData<-data.table::data.table()
          test_json<-assignmentClass(test_json, args)
          return(test_json)
        }
      )

    } else if(operations.type=="history") {
      # get the history
      .checkNum(x = AssId)
      url<-req_url_path_append(url, AssId, "history")
      if(!is.null(start)) url <- .addQuery(url, start = start)
      if(!is.null(length)) url <- .addQuery(url, length = length)
      tryCatch(
        { resp<-url |>
          httr2::req_perform()

        # get the response data
        if(resp_has_body(resp)){
          # get body by content type
          if(resp_content_type(resp) == "application/json") {
            test_json<-resp_body_json(resp, simplifyVector = TRUE)
            test_json$Assignments<-data.table::data.table(test_json$History)
            test_json<-assignmentClass(test_json, args)
            return(test_json)
          }
        }
        },
        error = function(e) {
          # return empty assignmentClass object
          test_json<-list()
          test_json$IdentifyingData<-data.table::data.table()
          test_json<-assignmentClass(test_json, args)
          return(test_json)
        }
      )

    } else if(operations.type=="recordAudio") {
      # get status of audio recording
      # Change the quantity
      .checkNum(x = AssId)
      url<-req_url_path_append(url, AssId, "recordAudio")
      tryCatch(
        { resp<-url |>
          httr2::req_perform()

        # get the response data
        if(resp_has_body(resp)){
          # get body by content type
          if(resp_content_type(resp) == "application/json") {
            test_json<-resp_body_json(resp, simplifyVector = TRUE)
            test_json$Assignments<-data.table::data.table(NULL)
            test_json<-assignmentClass(test_json, args)
            return(test_json)
          }
        }
        },
        error = function(e) {
          # return empty assignmentClass object
          test_json<-list()
          test_json$IdentifyingData<-data.table::data.table()
          test_json<-assignmentClass(test_json, args)
          return(test_json)
        }
      )

    }
  }
}



#' Survey Solutions API call for assignment manipulation
#'
#' \code{suso_set_assignments} allows to (re-)assign, change limits or audio
#' recording settings, as well as archiving/unarchive, downsizing, changing status/target area, and closing assignments.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param workspace If workspace name is provide requests are made regarding this specific workspace
#' @param AssId the assignment id for which the change is required
#' @param payload requirements depend on the operations type. See details below.
#' @param operations.type specifies the desired operation, one of recordAudio, archive, unarchive, assign,
#' changeQuantity, close, downsize, changeStatus, changeTargetArea.
#'
#' @details If operations.type is \emph{recordAudio}, \code{TRUE/FALSE} is required as payload.
#' If it is \emph{archive}, \emph{unarchive}, \emph{close}, or \emph{downsize}, no payload is required.
#' If it is \emph{assign} the payload must be the user ID (UUID) or username of the new responsible person (character, or data.frame/list with Responsible).
#' If it is \emph{changeQuantity} the payload must be the new integer number of assignments (-1 for unlimited).
#' If it is \emph{changeStatus} the payload must be the new status string (e.g. "Closed", "Deleted") or a named list with Status and optional Comment.
#' If it is \emph{changeTargetArea} the payload must be the new target area string.
#'
#' @return Returns an S3 object of assignmentClass
#'
#' @examples
#' \dontrun{
#'
#' # (re-)assign existing assignment by UUID, username, or data.frame
#' asslist<-suso_set_assignments(
#'                    workspace = "myworkspace",
#'                    AssId = 10,
#'                    payload = "43f3d2bd-7959-4706-97ae-2653b5685c9e",
#'                    operations.type = "assign"
#'                    )
#' asslist<-suso_set_assignments(
#'                    workspace = "myworkspace",
#'                    AssId = 10,
#'                    payload = data.frame(Responsible = "interviewer01"),
#'                    operations.type = "assign"
#'                    )
#' # downsize assignment
#' asslist<-suso_set_assignments(
#'                    workspace = "myworkspace",
#'                    AssId = 10,
#'                    operations.type = "downsize"
#'                    )
#' }
#'
#' @export
#' @import data.table

suso_set_assignments<-function(server = suso_get_api_key("susoServer"),
                               apiUser = suso_get_api_key("susoUser"),
                               apiPass = suso_get_api_key("susoPass"),
                               token = NULL,
                               workspace = suso_get_api_key("workspace"),
                               AssId=NULL,
                               payload = NULL,
                               operations.type = c("recordAudio",
                                                   "archive",
                                                   "assign",
                                                   "changeQuantity",
                                                   "close",
                                                   "unarchive",
                                                   "downsize",
                                                   "changeStatus",
                                                   "changeTargetArea")) {


  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  # check operations.type
  operations.type<-match.arg(operations.type)

  # check AssId
  .checkNum(x = AssId)

  # check payload by operations type
  if(operations.type=="recordAudio") {
    if (is.data.frame(payload) && ncol(payload) >= 1) payload <- payload[[1]][1]
    if (is.list(payload) && length(payload) >= 1) payload <- payload[[1]]
    if(!is.logical(payload)) {
      cli::cli_abort("payload must be TRUE/FALSE")
    }
    js_ch <- list(Enabled = jsonlite::unbox(payload))
  } else if(operations.type=="changeQuantity") {
    if (is.data.frame(payload) && ncol(payload) >= 1) payload <- payload[[1]][1]
    if (is.list(payload) && length(payload) >= 1) payload <- payload[[1]]
    if(!is.numeric(payload)) {
      cli::cli_abort("payload must be numeric")
    }
    if(!(payload == -1 || payload > 0)) {
      cli::cli_abort("payload must be positive integer or -1")
    }
    js_ch <- as.integer(payload)
  } else if(operations.type=="assign") {
    resp_val <- NULL
    if (is.data.frame(payload)) {
      if ("Responsible" %in% names(payload)) {
        resp_val <- payload$Responsible[1]
      } else if ("ResponsibleId" %in% names(payload)) {
        resp_val <- payload$ResponsibleId[1]
      } else if ("ResponsibleName" %in% names(payload)) {
        resp_val <- payload$ResponsibleName[1]
      } else if (ncol(payload) >= 1) {
        resp_val <- payload[[1]][1]
      }
    } else if (is.list(payload)) {
      if ("Responsible" %in% names(payload)) {
        resp_val <- payload$Responsible
      } else if ("ResponsibleId" %in% names(payload)) {
        resp_val <- payload$ResponsibleId
      } else if ("ResponsibleName" %in% names(payload)) {
        resp_val <- payload$ResponsibleName
      } else if (length(payload) >= 1) {
        resp_val <- payload[[1]]
      }
    } else if (is.character(payload) || is.factor(payload)) {
      resp_val <- as.character(payload)[1]
    }

    if (is.null(resp_val) || !nzchar(trimws(as.character(resp_val)))) {
      cli::cli_abort(c("x" = "payload for 'assign' must be a valid user ID (UUID) or username string (or data.frame/list containing Responsible)."))
    }

    resp_str <- trimws(as.character(resp_val))
    js_ch <- list(Responsible = jsonlite::unbox(resp_str))
  } else if(operations.type %in% c("close", "archive", "unarchive", "downsize")) {
    js_ch <- NULL
  } else if(operations.type == "changeStatus") {
    if (is.data.frame(payload)) {
      payload <- as.list(payload[1, ])
    }
    if (is.list(payload)) {
      js_ch <- payload
    } else {
      js_ch <- list(Status = jsonlite::unbox(as.character(payload)))
    }
  } else if(operations.type == "changeTargetArea") {
    if (is.data.frame(payload) && ncol(payload) >= 1) payload <- payload[[1]][1]
    if (is.list(payload) && length(payload) >= 1) payload <- payload[[1]]
    js_ch <- jsonlite::unbox(as.character(payload))
  }

  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "assignments")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "assignments")
  }

  # determine HTTP method
  http_method <- ifelse(operations.type %in% c("changeStatus", "changeTargetArea"), "POST", "PATCH")

  # add method to url
  url<-url |>
    httr2::req_method(http_method)

  # add AssId and operations.type to path
  url<-url |>
    httr2::req_url_path_append(AssId, operations.type)

  # add payload to body if not null
  if(!is.null(js_ch)) {
    url<-url |>
      httr2::req_body_json(js_ch)
  }

  # get argument for class
  args<-.getargsforclass(workspace = workspace)

  # Perform request
  tryCatch(
    { resp<-url |>
      httr2::req_perform()

    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = TRUE)
        test_json<-assignmentClass(test_json, args)
        return(test_json)
      }
    } else {
      # return empty assignmentClass
      test_json<-list()
      test_json$Assignments<-data.table::data.table(NULL)
      test_json<-assignmentClass(test_json, args)
      return(test_json)
    }
    },
    error = function(e) .http_error_handler(e, type = "ass")
  )

}


