#' General helper functions
#'
#' The functions in this file are used across all scripts in different locations.
#'
#'
#' @keywords internal
#' @noRd
#'

# .cli_alert_interactive<-function(msg, type = "info"){
#   if(interactive()) {
#     if(type=="info") cli::cli_alert_info(msg)
#     if(type=="warning") cli::cli_alert_warning(msg)
#     if(type=="error") cli::cli_alert_error(msg)
#   }
# }

.check_basics<- function(token, server, apiUser, apiPass) {
  if(is.null(token)){
    if(is.null(server) | is.null(apiUser) | is.null(apiPass)){
      cli::cli_abort(c("x" = "Please provide either a token or server, apiUser, and apiPass"))
    }
  } else {
    if(is.null(server)){
      cli::cli_abort(c("x" = "Please provide a server address"))
    }
  }
}

# drop empty columns (string/numeric) in dplyr pipline
.col_selector <- function(col) {
  return(!(all(is.na(col)) | all(col == "")))
}


# check input types
.checkNum<-function(x) {
  if (!is.numeric(x)) cli::cli_abort(c("x" = "Input must be numeric"))
}


## workspace default check
.ws_default<-function(ws=NULL){
  ## workspace default
  if(!is.null(ws)) {
    # margs<-suso_getWorkspace()$Name
    # workspace<-match.arg(workspace, margs)
    ws<-ws
  } else {
    if(interactive()) cli::cli_alert_info("No workspace provided. Using primary workspace.")
    ws<-"primary"
  }
  return(ws)
}

# check UUID format
.checkUUIDFormat <- function(id) {
  # Regular expression for UUID format: 8-4-4-4-12, also allow for version without -
  if(!is.null(id)) {
    hasHyphon<-stringr::str_detect(id, pattern = "-")
  } else {
    hasHyphon<-FALSE
  }
  if(hasHyphon) {
    uuid_pattern <- "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
  } else {
    uuid_pattern <- "^[0-9a-fA-F]{8}[0-9a-fA-F]{4}[0-9a-fA-F]{4}[0-9a-fA-F]{4}[0-9a-fA-F]{12}$"
  }
  if(!is.null(id) && grepl(uuid_pattern, id)) {
    invisible(TRUE)
  } else {
    cli::cli_abort(c("x" = "Invalid UUID format, or not provided. Please check your input."))
  }
}

# check suso key format
.checkIntKeyformat <- function(id) {
  # Regular expression for interview key format: 86-85-49-18
  key_pattern <- "^[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}$"

  if(grepl(key_pattern, id)) {
    invisible(TRUE)
  } else {
    stop("Invalid INterview Key format. Please check your input.")
  }
}

# check basic email format
.checkEmailFormat <- function(email) {
  # Basic email pattern: local-part@domain
  email_pattern <- "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"

  if(grepl(email_pattern, email)) {
    invisible(TRUE)
  } else {
    cli::cli_abort("Invalid email format. Please check your input.")
  }
}

# check date with lubridate -->ymd
.checkDate<- function(date_string) {
  # parse the date using ymd
  parsed_date <- ymd(date_string, quiet = TRUE)

  # Check if the parsed date is NA (invalid) or if the format is not as expected
  if (is.na(parsed_date) || format(parsed_date, "%Y-%m-%d") != date_string) {
    cli::cli_abort("Invalid date format. Please check your input.")

  } else {
    invisible(TRUE)
  }
}

# parse date and time and check against reference and return date time string
.genDateTimeCheckNow <- function(date_string,
                                 time_string,
                                 tz) {

  # Get System Time
  reference_time = now(tzone = tz)

  # Combine
  dateTimeString<-paste(date_string, time_string)

  # Combine into a dateTime object
  dateTime <- ymd_hms(dateTimeString, tz = tz)

  # Check if dateTime is earlier than reference time
  if (dateTime < reference_time) {
    cli::cli_abort("Provided date and time cannot be earlier than the reference time.")
  } else {

    # Return the valid dateTimeString object
    return(dateTimeString)
  }
}

# check time
.checkTime <- function(time_string) {

  # Parse the time using hms
  parsed_time <- hms(time_string, quiet = TRUE)

  # Check for validity, including hours, minutes, and seconds
  if (is.na(parsed_time) ||
      lubridate::hour(parsed_time) > 23 ||
      lubridate::minute(parsed_time) > 59 ||
      lubridate::second(parsed_time) > 59) {

    cli::cli_abort("Invalid time format. Please check your input.")

  } else {
    invisible(TRUE)
  }
}

# check date range
.checkDateRange <- function(from_date, to_date) {
  # Parse the dates
  parsed_from_date <- ymd(from_date, quiet = TRUE)
  parsed_to_date <- ymd(to_date, quiet = TRUE)

  # Check if either date is invalid
  if (is.na(parsed_from_date) || format(parsed_from_date, "%Y-%m-%d") != from_date ||
      is.na(parsed_to_date) || format(parsed_to_date, "%Y-%m-%d") != to_date) {
    cli::cli_abort("Invalid date format. Please check your input.")
  }

  # Check if from_date is not before to_date
  if(parsed_from_date > parsed_to_date) {
    cli::cli_abort("from_date must be before to_date")
  }
}

# check date time range
.checkDateTimeRange <- function(from_datetime, to_datetime) {
  # Parse the datetimes
  parsed_from_datetime <- ymd_hms(from_datetime, quiet = TRUE)
  parsed_to_datetime <- ymd_hms(to_datetime, quiet = TRUE)

  # Check if either datetime is invalid
  if (is.na(parsed_from_datetime) || format(parsed_from_datetime, "%Y-%m-%d %H:%M:%S") != from_datetime ||
      is.na(parsed_to_datetime) || format(parsed_to_datetime, "%Y-%m-%d %H:%M:%S") != to_datetime) {
    cli::cli_abort("Invalid date time format. Please check your input.")
  }

  # Check if from_datetime is not before to_datetime
  if(parsed_from_datetime >= parsed_to_datetime) {
    cli::cli_abort("from_date must be before to_date")
  }
}

# check time zone
.checkTimeZone<- function(time_zone) {
  valid_time_zones <- OlsonNames()

  if (time_zone %in% valid_time_zones) {
    invisible(TRUE)
  } else {
    cli::cli_abort(c("x" = "Invalid time zone name."))
    return(FALSE)
  }
}

# transform data.table char to date
.transform_datetime <- function(data_table) {
  # List of variables to be transformed
  variables_to_transform <- c("createdDate", "LastEntryDate", "ReceivedByDeviceAtUtc",
                              "calendarEvent.startUtc", "calendarEvent.updateDateUtc",
                              "UpdatedAtUtc", "ReceivedByTabletAtUtc", "startUtc",
                              "updateDateUtc", "importDateUtc")

  # Check and transform each variable
  for (var in variables_to_transform) {
    if (var %in% names(data_table)) {
      data_table[[var]] <- lubridate::as_datetime(data_table[[var]])
    }
  }

  return(data_table)
}


# get args from input values for class
.getargsforclass<-function(workspace = NULL) {
  # get all inputs except: server, apiUser, apiPass, token
  args<-as.list(match.call(
    definition = sys.function(-1),
    call = sys.call(-1)
  ))[-1]
  # remove server, apiUser, apiPass, token, by name with grepl
  args<-args[!grepl("server|apiUser|apiPass|token", names(args))]
  args$workspace<-workspace
  return(args)
}

# unnest nested dataframe in data.table
# !!!ATTENTION, COL IS UNQUOTED, ID IS QUOTED

.unnest_df_in_dt <- function(dt, col, id, name.var, valvar){
  stopifnot(is.data.table(dt))
  col <- substitute(unlist(col, recursive = FALSE))
  dtlong<-dt[, eval(col), by = id]
  dcarg<-sprintf("%s ~ %s", paste(id, collapse = "+"), name.var)
  dtwide <- dcast(dtlong,  eval(rlang::parse_expr(dcarg)),
                  value.var = valvar)
  dt<-merge(dt, dtwide, all.x = T)
  return(dt)

}

#' get number of cores with base r
#'
#' @noRd
#' @keywords internal
.detectCores <- function() {
  # Determine OS
  os <- .Platform$OS.type
  
  if (os == "unix") {
    # Check if it's macOS or Linux
    sys_info <- Sys.info()
    if (sys_info["sysname"] == "Darwin") {
      # macOS
      command <- "sysctl -n hw.logicalcpu"
    } else {
      # Linux and other Unix-like systems
      command <- "nproc"
    }
    
    # Execute the command
    result <- tryCatch(
      system(command, intern = TRUE, ignore.stderr = TRUE),
      error = function(e) NULL
    )
    
    if (!is.null(result) && length(result) > 0) {
      cores <- as.numeric(result[1])
      if (!is.na(cores) && cores > 0) {
        return(cores)
      }
    }
    
  } else if (os == "windows") {
    # Try multiple methods for Windows
    
    # Method 1: Try using environment variable (fastest and most reliable)
    cores <- as.numeric(Sys.getenv("NUMBER_OF_PROCESSORS"))
    if (!is.na(cores) && cores > 0) {
      return(cores)
    }
    
    # Method 2: Try PowerShell (more reliable on Windows 11)
    result <- tryCatch({
      system("powershell -Command \"(Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors\"", 
             intern = TRUE, ignore.stderr = TRUE)
    }, error = function(e) NULL)
    
    if (!is.null(result) && length(result) > 0) {
      cores <- as.numeric(result[1])
      if (!is.na(cores) && cores > 0) {
        return(cores)
      }
    }
    
    # Method 3: Try WMIC (might be deprecated in Windows 11)
    result <- tryCatch({
      system("WMIC CPU Get NumberOfLogicalProcessors /Value", 
             intern = TRUE, ignore.stderr = TRUE)
    }, error = function(e) NULL)
    
    if (!is.null(result) && length(result) > 0) {
      # Parse WMIC output
      for (line in result) {
        if (grepl("NumberOfLogicalProcessors", line)) {
          cores <- as.numeric(sub(".*=", "", line))
          if (!is.na(cores) && cores > 0) {
            return(cores)
          }
        }
      }
    }
  }
  
  # Ultimate fallback: use R's built-in function
  # return(parallel::detectCores())
}


#' get working memory
#'
#' @noRd
#' @keywords internal
.detectTotalMemory <- function() {
  # Determine OS
  os <- .Platform$OS.type

  # Define system command based on the OS
  if (os == "unix") {
    # Check for the type of Unix system and set command
    if (file.exists("/proc/meminfo")) {
      # Linux systems
      command <- "grep MemTotal /proc/meminfo | awk '{print $2}'"
    } else {
      # macOS and other Unix systems
      command <- "vm_stat | grep 'free' | awk '{print $3}' | sed 's/\\./'"
    }
  } else if (os == "windows") {
    command <- "wmic ComputerSystem get TotalPhysicalMemory"
  } else {
    stop("Unsupported operating system.")
  }

  # Execute the command
  result <- system(command, intern = TRUE)

  # Process the output
  if (os == "windows") {
    # Extract the number from the output and convert to megabytes
    memory <- as.numeric(result[2]) / 1024^2
  } else {
    memory <- as.numeric(result) / 1024
  }

  return(memory)
}








