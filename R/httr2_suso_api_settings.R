#' Survey Solutions API call for Headquarters Global Notice settings
#'
#' Allows getting, setting, and removing the global notice displayed in the Survey Solutions Headquarters application.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param action Action to perform: \code{"get"} to retrieve the notice, \code{"set"} to update the notice, or \code{"delete"} to remove the notice
#' @param message Character string containing the notice message. Required when \code{action = "set"}.
#'
#' @return When \code{action = "get"}, returns a character string with the current notice (or NULL if no notice is set).
#'   When \code{action = "set"} or \code{"delete"}, returns \code{TRUE} invisibly on success.
#'
#' @examples
#' \dontrun{
#' # Get current global notice
#' suso_globalNotice(action = "get")
#'
#' # Set a new global notice
#' suso_globalNotice(action = "set",
#'                   message = "Maintenance tonight at 22:00 UTC.")
#'
#' # Delete the global notice
#' suso_globalNotice(action = "delete")
#' }
#'
#' @export
suso_globalNotice <- function(server = suso_get_api_key("susoServer"),
                              apiUser = suso_get_api_key("susoUser"),
                              apiPass = suso_get_api_key("susoPass"),
                              token = NULL,
                              action = c("get", "set", "delete"),
                              message = NULL) {
  # check basics
  .check_basics(token, server, apiUser, apiPass)

  action <- match.arg(action)

  # Build base URL for settings endpoint (Headquarters-wide, no workspace)
  if (!is.null(token)) {
    url <- .baseurl_token(server, NULL, token, "settings") |>
      httr2::req_url_path_append("globalnotice")
  } else {
    url <- .baseurl_baseauth(server, NULL, apiUser, apiPass, "settings") |>
      httr2::req_url_path_append("globalnotice")
  }

  if (action == "get") {
    url <- httr2::req_method(url, "GET")
    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "wsp")
    )
    if (httr2::resp_has_body(resp) && httr2::resp_content_type(resp) %in% c("application/json", "text/json")) {
      res <- httr2::resp_body_json(resp)
      return(res$Message)
    } else {
      return(NULL)
    }
  } else if (action == "set") {
    if (is.null(message) || !is.character(message) || nchar(trimws(message)) == 0) {
      cli::cli_abort(c("x" = "A non-empty 'message' string must be provided when action is 'set'."))
    }
    url <- url |>
      httr2::req_method("PUT") |>
      httr2::req_body_json(list(Message = message))

    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "wsp")
    )

    if (httr2::resp_status(resp) == 204) {
      if (interactive()) {
        cli::cli_alert_success("Global notice updated successfully.")
      }
      return(invisible(TRUE))
    }
    return(invisible(FALSE))
  } else if (action == "delete") {
    url <- httr2::req_method(url, "DELETE")
    resp <- tryCatch(
      httr2::req_perform(url),
      error = function(e) .http_error_handler(e, "wsp")
    )

    if (httr2::resp_status(resp) == 204) {
      if (interactive()) {
        cli::cli_alert_success("Global notice deleted successfully.")
      }
      return(invisible(TRUE))
    }
    return(invisible(FALSE))
  }
}
