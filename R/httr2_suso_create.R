#' Survey Solutions API call for Assignment Creation
#'
#'
#' Creates assignment with ID data. Uses the httr2 package,
#' and specifically the \code{\link[httr2]{req_perform_parallel}} function. Compared to a sequential approach, this significantly
#' and safely decreases the overall processing time. Adjust relevant option \option{suso.maxpar.req} for number of parallel processes to
#' match the capacity of your system (default is 100 parallel requests).
#'
#' @param df dataframe with upload data for ID (identifying data) assignments, see details for structure.
#' @param server Survey Solutions server address.
#' @param apiUser Survey Solutions API user.
#' @param apiPass Survey Solutions API password.
#' @param workspace server workspace, if nothing provided, defaults to primary.
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored.
#' @param questID the questionnaire id.
#' @param version the questionnaire version.
#'
#' @details Dataframe needs to be provided with columns
#' for ID data, matching the required type, as well as \emph{Quantity} and \emph{ResponsibleName}. Return value is a data.table,
#' with the ID data, if successful.
#'
#' @return Returns a data.table with a row for each assignment, containing identifying data, responsible id etc.
#'
#' @examples
#' \dontrun{
#'
#' # get the list of questionnaires in the workspace
#' questlist<-suso_getQuestDetails()
#'
#'
#' # Create the assignments with your upload data
#' asslist <- suso_createASS(df = IdentifyingData,
#'                           questID = questlist$QuestionnaireId[1],
#'                           version = questlist$Version[1])
#'
#' }
#'
#'
#'
#' @export
#'
#'

suso_createASS <- function(df = NULL,
                           server = suso_get_api_key("susoServer"),
                           apiUser = suso_get_api_key("susoUser"),
                           apiPass = suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           questID = NULL,
                           version = NULL) {
  # A. Check if all inputs are provided except for workspace which can be NULL
  if (is.null(df) | is.null(server) | is.null(apiUser) | is.null(apiPass) | is.null(questID) | is.null(version)) {
    cli::cli_abort(c("x" = "Not all required inputs have been provided. Please check."))
  }

  # B. Check if is data.table if not transform to data.table
  if (!is.data.table(df)) {
    df <- data.table::as.data.table(df)
  }
  # C. Copy data.table to avoid side effects
  df <- data.table::copy(df)

  # D. Default workspace
  workspace <- .ws_default(ws = workspace)

  # E. Base URL and path
  base_url <- server
  # path <- file.path(workspace, "api", "v1", "assignments")

  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    base_url<-.baseurl_token(base_url, workspace, token, "assignments")
  } else {
    base_url<-.baseurl_baseauth(base_url, workspace, apiUser, apiPass, "assignments")
  }

  # F. Questionnaire ID
  quid <- paste0(questID, "$", version)

  # G. Transform input df
  respname<-df$ResponsibleName
  quant<-df$Quantity
  df[, `:=`(ResponsibleName, NULL)][, `:=`(Quantity, NULL)]
  df<-as.data.frame(df)

  # put warning when no identification data
  if(interactive()) {
    cli::cli_alert_warning("Assignment creation without identifying data.")
  }

  # H. Request
  # H.1. Function to generate requests
  genrequests<- function(i, base_url, respname, quant, quid, df) {
    if(nrow(df)>0) {
      js_ch <- list(
        Responsible = unbox(respname[i]),
        Quantity = unbox(quant[i]),
        QuestionnaireId = unbox(quid),
        IdentifyingData = data.frame(Variable = c(names(df)),
                                     Identity = rep("", length(names(df))),
                                     Answer = c(unlist(df[i,], use.names = FALSE)))
      )
    } else {
      js_ch <- list(
        Responsible = unbox(respname[i]),
        Quantity = unbox(quant[i]),
        QuestionnaireId = unbox(quid)
      )
    }
    req <- base_url  |>
      req_body_json(js_ch)  |>
      req_method("POST")

    return(req)
  }
  # H.2. Execute request generation
  # requests <- lapply(1:nrow(df), genrequests)

  requests<-.gen_lapply_with_progress(
    seq_along(respname),
    genrequests,
    "requests", "assignment", workspace,
    base_url, respname, quant, quid, df
  )

  # H.3. Perform requests in parallel
  responses <- httr2::req_perform_parallel(
    requests,
    max_active = getOption("suso.maxpar.req"),
    on_error = "continue"
  )

  # if(FALSE) return(responses)
  # I. Response
  # I.1. Get faild responses
  failed<-responses %>% httr2::resps_failures()
  # I.2. Get successful responses
  responses<-responses %>% resps_successes()
  # I.2.1. Check if there are any successful responses and stop if not
  if(length(responses)==0){
    cli::cli_abort(c("x" = "No successful responses"), call = NULL)
  }
  # I.3. Create dataframe from successful responses
  # I.3.1. Function to transform response to dataframe
  transformresponse<-function(i, allresp) {
    # i. Convert to json
    resp<-allresp[[i]]
    respfull <-resp %>%
      resp_body_json(simplifyVector = T, flatten = TRUE)

    # ii. Get identifying data
    # transform to wide format
    resp<-data.frame(respfull$Assignment$IdentifyingData)
    # skip when id dataframe is 0 rows
    if(nrow(resp)>0) {
      reshaped_data <- as.vector(t(resp))
      new_col_names <- paste0(rep(names(resp), each = nrow(resp)), 1:nrow(resp))
      resp<-setNames(data.frame(matrix(reshaped_data, ncol = length(reshaped_data), byrow = TRUE)), new_col_names)
    } else if(nrow(resp)==0) {
      resp<-data.frame(NO_ID_DATA="NO ID DATA LOADED")
    }
    # iii. Get other data
    nodf<-names(respfull$Assignment)[!grepl("IdentifyingData", names(respfull$Assignment))]
    for(x in nodf){
      resp[[x]] <- respfull$Assignment[[x]]
    }
    return(resp)
  }
  # transform w lapply
  status_list<-.gen_lapply_with_progress(
    responses,
    transformresponse,
    "responses", "assignments", workspace,
    responses
  )
  # Convert to data.table and bind
  status_list<-data.table::rbindlist(status_list, fill = TRUE)

  # Transform Columns
  if(nrow(status_list)>0) {
    # transform date
    status_list[,CreatedAtUtc:=lubridate::as_datetime(CreatedAtUtc)][,UpdatedAtUtc:=lubridate::as_datetime(UpdatedAtUtc)]
  }

  return(status_list[])
}










