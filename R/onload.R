.onLoad <- function(...){
  ## taken from googleway package
  ##  creates options list

  if(is.null(getOption("SurveySolutionsAPI"))) {

    options <- list(
      suso = list(
        susoServer = NA_character_,
        susoUser = NA_character_,
        susoPass = NA_character_,
        workspace = NA_character_
      )
    )
    attr(options, "class") <- "suso_api"
    options(SurveySolutionsAPI = options)
  }
  
  # add http option
  if(is.null(getOption("suso.url.http"))) {
    options(suso.url.http = FALSE)
  }
  # parallel requests
  if(is.null(getOption("suso.maxpar.req"))) {
    options(suso.maxpar.req = 100)
  }
  if(is.null(getOption("suso.maxpar.con"))) {
    # if max requests not NULL, then set con to same
    options(suso.maxpar.con = min(100, getOption("suso.maxpar.req")))
  }

  # package specific options
  if(is.null(getOption("suso.para.break"))) {
    options(suso.para.break = 120)
  }
  # tz defaults to system tz
  if(is.null(getOption("suso.para.tz"))) {
    options(suso.para.tz = Sys.timezone())
  }

  # number of cores for parallel processing
  if(is.null(getOption("suso.para.maxcore"))) {
    detected <- tryCatch(parallel::detectCores(), error = function(e) 2L)
    if (is.na(detected) || is.null(detected)) detected <- 2L
    cores <- max(1L, as.integer(detected - 2L))
    if (identical(Sys.getenv("_R_CHECK_LIMIT_CORES_"), "TRUE")) {
      cores <- min(cores, 2L)
    }
    options(suso.para.maxcore = cores)
  }

  # type of parallel i.e. multisession, sequential multicore
  if(is.null(getOption("suso.para.plan"))) {
    options(suso.para.plan = "multisession")
  }

  # option to use shiny features (i.e. showNotification)
  if(is.null(getOption("suso.useshiny"))) {
    options(suso.useshiny = TRUE)
  }
  if(is.null(getOption("suso.progressbar.message"))) {
    options(suso.progressbar.message = "Creating new export file")
  }
  if(is.null(getOption("suso.pwcheck.message_succ"))) {
    options(suso.pwcheck.message_succ = "Credentials are correct and a successful
                                request\n was performed in workspace %s")
  }
  if(is.null(getOption("suso.pwcheck.message_fail"))) {
    options(suso.pwcheck.message_fail = "Credentials are incorrect and a failed
                                request\n was performed in workspace %s")
  }
}
