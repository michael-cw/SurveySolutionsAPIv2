#' Configuration options used for the SurveySolutionsAPIv2 package
#'
#' @description
#' Below are the options and environment variables, that are used by the \pkg{SurveySolutionsAPIv2} package.
#'
#' @section Available options:
#' Bellow is a list of options, with their default values.
#'
#' \itemize{
#'   \item \option{suso.url.http} if TRUE allows for non SSL connections, which is generally not recommended for publicly facing set-ups, however
#'   may be required for testing purposes.
#'   \item \option{suso.maxpar.req} specifies the maximum number of parallel requests, default is 100.
#'   \item \option{suso.maxpar.con} specifies the maximum number of parallel connections,
#'   and must always be equal or greater than suso.maxpar.req, default is 100.
#'   \item \option{suso.para.break} specifies the maximum response time to be considered as a break in seconds, default 120.
#'   \item \option{suso.para.tz} specifies the local timezone for the processing of time values, default is \code{Sys.timezone()}.
#'   \item \option{suso.para.maxcore} specifies the number of cores used for parallel processing, default is \code{data.table::getDTthreads()-2}.
#'   \item \option{suso.para.plan} specifies plane used for parallel processing, default is \code{multisession}. For details please see
#'   \code{future::\link[future]{plan}}
#'   \item \option{suso.useshiny} should R shiny elements be used if running in shiny app, default is TRUE. Currently implemented for:
#'   \itemize{
#'      \item \code{\link{suso_PwCheck}}, providing feedback for credentials check, the \option{suso.pwcheck.message_succ} and \option{suso.pwcheck.message_fail} can
#'      be modified.
#'      \item \code{\link{suso_export}}, providing different progress bars for interactive (cli) use and in shiny app use (\code{shiny::\link[shiny]{withProgress}},
#'      to also customize the progress bar message, i.e. in a different language, the \option{suso.progressbar.message} can
#'      be modified.
#'      \item TBD
#'   }
#' }
#'
#' @return No return value, called for documentation on package configuration options.
#'
#' @examples
#' # Inspect the current maximum parallel requests option
#' getOption("suso.maxpar.req", default = 100)
#'
#' # Inspect the timezone option
#' getOption("suso.para.tz", default = Sys.timezone())
#'
#' @name suso.options
#'
NULL


#' Convenience Function to modify the maximum number of parallel requests option
#'
#' @description
#' This function allows to modify the maximum number of parallel requests \option{suso.maxpar.req}
#' in a single call. It also checks the maximum number of parallel connections, and if lower than
#' the number of requests \code{max_req} then also sets the \option{suso.maxpar.con} option to
#' \code{max_req}.
#'
#' @param max_req set the number of parallel requests for all functions which
#'
#' @return Invisible NULL.
#' @export
#'
#' @examples
#' # Set maximum parallel requests to 50
#' suso_set_maxpar_req(50)
#' # Reset back to default
#' suso_set_maxpar_req(100)
#'
suso_set_maxpar_req <- function(max_req = 100) {
  options(suso.maxpar.req = as.integer(max_req))
  if(interactive()) cli::cli_alert_info("Maximum parallel requests set to {max_req}.")
  max_con<-getOption("suso.maxpar.con")
  if (is.null(max_con) || max_con < max_req) {
    options(suso.maxpar.con = max_req)
    if(interactive()) cli::cli_alert_warning("Also adjusted maximum parallel connections to {max_req}.")
  }
  invisible(NULL)
}


#' Convenience functions to modify user notification text
#'
#' @description
#' These functions allow the user to customize certain notifications and messages when used in shiny apps.
#'
#' @param mess_succ set the success message for \code{\link{suso_PwCheck}} when used in shiny app.
#' @param mess_fail set the success message for \code{\link{suso_PwCheck}} when used in shiny app.
#'
#' @return always invisible \code{TRUE}.
#'
#' @rdname suso-shiny-messages
#' @family suso-customization-options
#'
#' @export
#'
#' @examples
#' # Set custom notification messages for shiny app
#' suso_set_pwcheck_mess(mess_succ = "Connected successfully!", mess_fail = "Authentication failed!")
#' suso_set_prog_mess(mess = "Downloading data, please wait...")
#'
suso_set_pwcheck_mess<-function(mess_succ = NULL, mess_fail = NULL) {

  if(!is.null(mess_succ)) {
    m<-paste(mess_succ, "%s")
    options(suso.pwcheck.message_succ = m)
  }

  if(!is.null(mess_fail)) {
    m<-paste(mess_fail, "%s")
    options(suso.pwcheck.message_fail = m)
  }
  invisible(TRUE)
}

#' @param mess set the message for the export progress bars when used in shiny app, used in \code{\link{suso_export}} and \code{\link{suso_export_paradata}}
#'
#' @rdname suso-shiny-messages
#' @family suso-customization-options
#'
#' @export
suso_set_prog_mess<-function(mess = NULL) {

  if(!is.null(mess)) {
    options(suso.progressbar.message = mess)
  }
  invisible(TRUE)
}

