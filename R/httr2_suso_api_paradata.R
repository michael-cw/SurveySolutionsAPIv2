#'  Export Survey Solutions paradata
#'
#' Exports Survey Solutions paradata, and returns either a single exportClass data.table,
#' or a list of data.tables.
#'
#'
#'  \code{suso_export_paradata} returns a data.table. Calculates the response time
#'  and separates multiple responses into individual columns. It also creates a variable
#'  \emph{counter} which preserves the sequence of events.
#'
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param workStatus define which statuses the file should inlude (i.e. \emph{Restored,Created,SupervisorAssigned,InterviewerAssigned,
#' RejectedBySupervisor,ReadyForInterview,
#' SentToCapi,Restarted,Completed,ApprovedBySupervisor,
#' RejectedByHeadquarters,ApprovedByHeadquarters,Deleted}), if NULL all is exported
#' @param questID \emph{QuestionnaireId} for which the paradata should be generated
#' @param version questionnnaire version
#' @param from_date if provided, only interviews started on this date or later will be included
#' @param from_time if provided, only interviews started at this time or later will be included
#' @param to_date if provided, only interviews started before or on this date will be included
#' @param to_time if provided, only interviews started before or at this time will be included
#' @param reloadTimeDiff time difference in hours between last generated file and now (will be ignored when \code{from_date} and
#' \code{to_date} is not \code{NULL})
#' @param inShinyApp if True, file interacts with shiny progress bar
#' @param multiCore if not NULL, an integer number specifying the number of cores to use
#' @param onlyActiveEvents if TRUE only active events are exported, decreases processing time and memory requirements
#' @param asList only used if \code{onlyActiveEvents = T}, if TRUE returns a list with a separate list element for each event, if FALSE returns
#' a single \emph{exportClass} data.table object. See details for more information.
#' @param allResponses if TRUE all responses will be extracted. Setting it to FALSE may decrease processing time and
#' memory requirements
#' @param gpsVarName provide GPS variable name. If not provided, identification is attempted by lookin for a variable containing gps in its name.
#' @param verbose if TRUE, shows messages about the operation carried out. Can be useful for longrunning operations.
#' @param showProgress also display the progress bars.
#'
#' @details The return value is a list with a separate list element for each event. If any of the variable
#' names contains \emph{gps} this function also attempts to identify (and extract) the geo-reference location. In case of multiple gps variables,
#' it identifies the first variable, with not all missing values. This in turn
#' facilitates the creation of paradata maps (see vignette on paradata). In addition it also returns all the variables and responses in separate columns and
#' as factors.
#' Exporting \emph{onlyActiveEvents} substantially decrease processing time. The events may be sufficient for most of the paradata analysis.
#'
#' To further decrease the processing time, one could set \emph{allResponses} to FALSE. Doing so will still export all the data, however it will
#' not attempt to extract all responses and setting them to factors.
#'
#' @return a single exportClass data.table or a list of data.tables.
#'
#' @examplesIf suso_PwCheck() == 200
#' \donttest{
#' questlist<-suso_getQuestDetails()
#' # Get a single data.table with response timings,
#' # only active events,
#' # and responses are not expanded
#' para<-suso_export_paradata(questID = questlist$QuestionnaireId[1],
#'                            version = questlist$Version[1],
#'                            reloadTimeDiff = 0,
#'                            workStatus = "All",
#'                            asList = FALSE,
#'                            onlyActiveEvents = TRUE,
#'                            allResponses = FALSE)
#'
#' # Create a summary table
#' summary_data_table <- summaryTable(para)
#'
#' # Display the summary table
#' summary_data_table
#' }
#'
#' @export
#'

suso_export_paradata<-function(server = suso_get_api_key("susoServer"),
                               apiUser = suso_get_api_key("susoUser"),
                               apiPass = suso_get_api_key("susoPass"),
                               token = NULL,
                               workspace = suso_get_api_key("workspace"),
                               questID = NULL,
                               version = NULL,
                               from_date = NULL,
                               from_time = "00:00:00",
                               to_date = NULL,
                               to_time = "23:59:59",
                               workStatus=c("All", "SupervisorAssigned", "InterviewerAssigned",
                                            "RejectedBySupervisor", "Completed",
                                            "ApprovedBySupervisor",
                                            "RejectedByHeadquarters",
                                            "ApprovedByHeadquarters"),
                               reloadTimeDiff=1,
                               inShinyApp=FALSE,
                               multiCore = NULL,
                               onlyActiveEvents = FALSE, asList = FALSE,
                               allResponses = TRUE,
                               gpsVarName = NA,
                               verbose = FALSE,
                               showProgress = FALSE){
  extype<-"Paradata"
  ######################################################################################
  ##          SETUP
  # workspace default
  workspace<-.ws_default(ws = workspace)
  
  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)
  
  # check if workStatus is valid
  workStatus<-match.arg(workStatus)
  
  # check if questID is provided & correct
  if(is.null(questID)){
    stop("Please provide a questionnaire ID")
  } else {
    .checkUUIDFormat(questID)
  }
  
  # check if version is provided & numeric
  if(is.null(version)){
    stop("Please provide a questionnaire version")
  } else if(length(version) > 1) {
    stop("Please provide a questionnaire version")
  } else {
    .checkNum(version)
  }
  
  # parse questID and version to id$version
  qid<-paste0(questID, "$", version)
  qid<-stringr::str_remove_all(qid, "-")
  
  # check from_date if provided
  if(!is.null(from_date)){
    .checkDate(from_date)
  }
  
  # check to_date if provided, if not and from_date is provided, set to_date to today
  if(!is.null(to_date)){
    .checkDate(to_date)
  } else if(!is.null(from_date)){
    to_date<-lubridate::today()
  }
  
  # check if from_date is before to_date
  if(!is.null(from_date) & !is.null(to_date)){
    .checkDateRange(from_date, to_date)
  }
  
  # build from datetime and to datetime
  if(!is.null(from_date)){
    from_datetime<-paste(from_date, from_time)
    
    # if to_time is not provided, set to_time to 23:59:59
    if(is.null(to_time)){
      nt<-now()
      to_time<-format(nt, "%H:%M:%S")
    }
    
    to_datetime<-paste(to_date, to_time)
    .checkDateTimeRange(from_datetime, to_datetime)
  } else {
    from_datetime<-NULL
    to_datetime<-NULL
  }
  
  
  # Build the URL, first for token, then for base auth
  if(!is.null(token)){
    url<-.baseurl_token(server, workspace, token, "export", version = "v2")
  } else {
    url<-.baseurl_baseauth(server, workspace, apiUser, apiPass, "export", version = "v2")
  }
  
  # get argument for class
  args<-.getargsforclass(workspace = workspace)
  
  url_w_query<-.addQuery(url, exportType="Paradata",
                         interviewStatus=workStatus,
                         questionnaireIdentity = qid,
                         exportStatus="Completed",
                         hasFile=TRUE)
  
  
  # check if export file with same parameters is is available
  tryCatch(
    { resp<-url_w_query |>
      httr2::req_perform()
    
    # get the response data
    if(resp_has_body(resp)){
      # get body by content type
      if(resp_content_type(resp) == "application/json") {
        test_json<-resp_body_json(resp, simplifyVector = TRUE)
        exlist<-data.table::data.table(test_json)
      }
    } else {
      exlist<-data.table(character(0))
    }
    },
    error = function(e) .http_error_handler(e, "exp")
  )
  
  # CHECK for existing files
  if(nrow(exlist)>0) {
    exlist<-exlist[ExportType==extype]
    # subset existing exports & check time diff parameter with last creation date
    # 1. Check qid
    exlist_sub<-exlist[QuestionnaireId==qid]
    exlist_sub<-exlist_sub[HasExportFile==TRUE]
    
    # 2. Check other paramters -->TD
    
    # 3. Check reload time diff (= difference between last file in
    # exlist start time)
    if(nrow(exlist_sub)>0) {
      .checkNum(reloadTimeDiff)
      
      # Check for from/to date/time
      if(!is.null(from_datetime) && !is.null(to_datetime)) {
        # create new when from/to is provided
        if(interactive()) {
          cli::cli_alert_success(
            "From Date/time {from_datetime} and To Date/time {to_datetime} has been provided.
          A new file with these parameters will be created."
          )
        }
        exlist_sub<-data.table(character(0))
      } else if(!is.null(reloadTimeDiff)) {
        time_limit<-exlist_sub[1, StartDate]
        time_limit<-lubridate::as_datetime(time_limit)
        # current time (!! in UTC)
        current_time<-lubridate::now(tzone = lubridate::tz(time_limit))
        # time difference between now and last start
        timeDiff<-difftime(current_time, time_limit, units = "hours")
        # If reloadtime is smaller, download existing, otherwise new
        if(!is.null(timeDiff) && length(timeDiff)>0 && timeDiff<=reloadTimeDiff) {
          if(interactive()) {
            cli::cli_alert_success(
              "Existing file within desired reload time difference
          of {as.integer(reloadTimeDiff)} hour(s)."
            )
          }
          exlist_sub<-exlist_sub[1]
          
        } else {
          if(interactive()){
            cli::cli_alert_info(
              "Existing file older than desired reload time difference
          of {as.integer(reloadTimeDiff)} hour(s). Creating new export"
            )
          }
          exlist_sub<-data.table(character(0))
        }
      } else {
        cli::cli_abort(c("x" = "You have to either provide a value for the reload time difference, or a from_date/time."))
      }
      
    }
  } else {
    exlist_sub<-data.table(character(0))
  }
  
  if(nrow(exlist_sub)>0) {
    # Get latest available file id (data sorted by date)
    jobid<-exlist_sub[1,JobId]
    
    if(interactive()){
      cli::cli_alert_success(
        "\nDownloading existing file with JobID {jobid}.\n"
      )
    }
    
    url<-url |>
      req_method("GET") |>
      req_url_path_append(jobid, "file") |>
      # add curl options (automatic redirect does not work!)
      httr2::req_options(
        followlocation = 1L,
        unrestricted_auth = 0L,
        tcp_keepalive = 1L
      )
    
  } else {
    # if exlist_sub is empty, start new export file
    
    if(interactive()){
      cli::cli_alert_info(
        "\nCreating new export file. This may take a while.\n"
      )
    }
    
    # add method post
    url<-url |>
      req_method("POST")
    
    # creat body list
    js_body<-list(
      ExportType = "Paradata", #required
      QuestionnaireId = qid, #required
      InterviewStatus = workStatus, #required
      From = from_datetime, # can be null
      To = to_datetime, # can be null
      TranslationId = NULL, #!!!MUST BE INCLUDED AND SET TO NULL OTHERWISE EXP IN SEC
      IncludeMeta = FALSE #required to be TRUE because otherwise, export is in SECONDS
    )
    
    # add body
    url<-url |>
      req_body_json(
        js_body
      )
    
    # create new export file
    tryCatch(
      { resp<-url |>
        httr2::req_perform()
      
      # get the response data
      if(resp_has_body(resp)){
        # get body by content type
        if(resp_content_type(resp) == "application/json") {
          test_json<-resp_body_json(resp, simplifyVector = TRUE)
          exlist1<-data.table::as.data.table((test_json))
          # name cancel and file link
          if(nrow(exlist1)==2) {
            exlist1[,LinkType:=c("cancel","download")][]
          }
          # return(exlist1)
        }
      }
      },
      error = function(e) .http_error_handler(e, "exp")
    )
    
    # check file status, and if creation completed, download
    jobid<-exlist1$JobId[1]
    status<-exlist1$ExportStatus[1]
    prog<-1 #exlist1$Progress[1]
    # remove json body
    url$body<-NULL
    # update path for details request
    url<-url |>
      req_method("GET") |>
      req_url_path_append(jobid)
    
    # perform request in while loop until file is ready
    # i. add progress bar
    cli::cli_progress_bar(getOption("suso.progressbar.message"), total = 150, type = "iterator")
    # on exit always close pb otherwise error?
    on.exit(cli::cli_progress_done())
    # ii. add while loop
    while(status != "Completed"){
      # get status
      tryCatch(
        { resp<-url |>
          httr2::req_perform()
        
        # get the response data
        if(resp_has_body(resp)){
          # get body by content type
          if(resp_content_type(resp) == "application/json") {
            test_json<-resp_body_json(resp, simplifyVector = TRUE)
            status<-test_json$ExportStatus
            progresp<-test_json$Progress
          }
        }
        },
        error = function(e) .http_error_handler(e, "exp")
      )
      # update progress bar -->SuSo not always reports correctly. if call is completed, set to 100
      prog<-ifelse(prog>progresp, prog+1, progresp)
      prog<-ifelse(status=="Completed", 98, prog)
      if(status!= "Completed") cli::cli_progress_update(set = prog) else cli::cli_progress_done()
    }
    
    # when finished get file
    url<-url |>
      req_method("GET") |>
      req_url_path_append("file") |>
      # add curl options (automatic redirect does not work!)
      httr2::req_options(
        followlocation = 1L,
        unrestricted_auth = 0L,
        tcp_keepalive = 1L
      )
    
  }
  
  # PROCESSING OF DOWNLOAD
  # DEBUG: print all inputs for check
  if(verbose){
    message("Server: ", server)
    message("Workspace: ", workspace)
    message("Url: ", url$url)
    message("Questionnaire ID: ", questID)
    message("Questionnaire Version: ", version)
    message("From Date: ", from_date)
    message("From Time: ", from_datetime)
    message("To Date: ", to_date)
    message("To Time: ", to_datetime)
    message("Work Status: ", workStatus)
    #message("Add Translation: ", addTranslation)
    message("Reload Time Difference: ", reloadTimeDiff)
    message("In Shiny App: ", inShinyApp)
  }
  
  
  # temp zip file
  tmp<-tempfile(fileext = ".zip")
  # download file
  tryCatch(
    { resp<-url |>
      httr2::req_perform(path = tmp)
    },
    error = function(e) .http_error_handler(e, "exp")
  )
  
  # unzip file with unzip package
  # create temp directory jobid
  tmpdir<-file.path(tempdir(), jobid)
  if(!dir.exists(tmpdir)) dir.create(tmpdir)
  # unzip file
  zip::unzip(tmp, exdir = tmpdir)
  
  # iii. created list with questions and validations
  allcontent<-suso_getQuestDetails(questID = questID, version = version, workspace = workspace, apiUser = apiUser, apiPass = apiPass,
                                   server = server, operation.type = "structure")
  allquestions<-allcontent$q
  qgps<-.questionnaire_gpsquestion(allquestions)
  if(nrow(qgps)>0) qgps<-qgps[type1 == "GPS"]
  
  #aaa<-data.table::fread(file.path(tempdir(), 19474, "paradata.tab"), sep = "\t")
  fp<-file.path(tmpdir, "paradata.tab")
  
  ## UNPACK
  paradata_files<-.unpack(fp=fp, allResponses = allResponses, inShinyServer = inShinyApp)
  
  # aaa$AnswerSet[var!= "<NA>",.(av_duration=mean(duration)), by=.(var)]
  
  ## ALERT when empty, BUT RETUNR EMPTY DATA.TABLE
  if (is.null(paradata_files)) {
    if(interactive()) cli::cli_alert_danger("No data with work status: {workStatus}")
    
    return(data.table::data.table(NULL))
  }
  if(inShinyApp) incProgress(amount = 0.25, message = "Transformation completed")
  ## TRANSFORMATIONS
  ## A add rid if it doesnt exist
  if (!("rid" %in% names(paradata_files))) paradata_files[,rid:=0]
  
  para_data<-list()
  
  ##################################################################
  ##  2.1. Get Start/End date
  #fromDate<-as.character(min(paradata_files$date, na.rm = T), "%d %B, %Y")
  #toDate<-as.character(max(paradata_files$date, na.rm = T), "%d %B, %Y")
  
  paradata_files<-paradata_files[,VariableName:=var]
  paradata_files <- merge(paradata_files, allquestions[,.(VariableName, type, QuestionText, Featured)], all.x = TRUE, by = "VariableName")
  paradata_files[,VariableName:=NULL]
  
  
  ##################################################################
  ##  2.2. GET ALL ACTION COUNTS
  actionDistr<-paradata_files[,.(count=.N), by=.(action)]
  setorderv(actionDistr, "count", order = -1)
  ##################################################################
  ##  2.3. GET ALL RESPONSIBLE COUNTS
  userDistr<-paradata_files[,.(count=.N), by=.(responsible)]
  setorderv(userDistr, "count", order = -1)
  ##################################################################
  ##  2.4. GET ALL ROLE COUNTS
  roleDistr<-paradata_files[,.(count=.N), by=.(role)]
  setorderv(roleDistr, "count", order = -1)
  
  ##  2.5. Extract questionnaire ID and Key
  KeyAssigned<-paradata_files[action=="KeyAssigned"][,c("responsible", "role", "var_resp", "rid"):=NULL]
  setnames(KeyAssigned, "var", "key")
  KeyAssigned<-droplevels(KeyAssigned)
  paradata_files<-paradata_files[action!="KeyAssigned"]
  paradata_files<-droplevels(paradata_files)
  KeyAssigned<-KeyAssigned[,.SD[1], by=.(interview__id)]
  KeyAssigned_merge<-KeyAssigned[ ,.(interview__id, key)]
  setkeyv(KeyAssigned, "interview__id")
  para_data$KeyAssigned<-KeyAssigned
  ##  2.6. Comments
  CommentSet<-paradata_files[action=="CommentSet"]
  if(nrow(CommentSet)>0){
    setnames(CommentSet, "var_resp", "comment")
    CommentSet<-droplevels(CommentSet)
    paradata_files<-paradata_files[action!="CommentSet"]
    paradata_files[,action:=droplevels(action)]
    para_data$CommentSet<-CommentSet
  }
  ## 2.7 Completed
  Completed<-paradata_files[action=="Completed"][,c("responsible", "role" ,"var_resp", "rid"):=NULL]
  if(nrow(Completed)>0){
    setnames(Completed, "var", "comment")
    Completed<-droplevels(Completed)
    paradata_files<-paradata_files[action!="Completed"]
    paradata_files[,action:=droplevels(action)]
    para_data$Completed<-Completed
  }
  ##  2.8. AnswerSet
  para1_answer<-paradata_files[action=="AnswerSet"|action=="Paused"]
  para1_answer[,action:=droplevels(action)]
  
  ##  3. Time Difference (SORT by counter)
  ##  3.1. Function (use shift/lead, and check lead date is the same)
  if(verbose) message("Calculating Response Timings.")
  para1_answer<-.calcTimeDiff(para1_answer)
  ##  3.2. Other calculations
  para1_answer<-para1_answer[!is.na(breaks)]
  para1_answer[,duration:=round((sum(resp_time, na.rm = TRUE))/60, 4), by = .(interview__id)]
  para1_answer[breaks==0,durationNOBREAK:=round((sum(resp_time, na.rm = TRUE))/60, 4), by = .(interview__id)]
  para1_answer[,m_resp_time_varTRIM:=(mean(resp_time, na.rm = TRUE, trim = 0.05)), by = .(var)]
  para1_answer[,m_resp_time_var:=(mean(resp_time, na.rm = TRUE)), by = .(var)]
  para1_answer[breaks==0,m_diff_dev:=resp_time-m_resp_time_varTRIM]
  para1_answer[,start:=as_datetime(min(dateTime, na.rm = TRUE), tz = getOption("suso.para.tz")), by=.(interview__id)]
  para1_answer[,startHour:=min(hour(time), na.rm = TRUE), by=.(interview__id)]
  para1_answer[,role:=droplevels(role)][,responsible:=droplevels(responsible)]
  para1_answer[,var:=as.factor(var)]
  para1_answer_merge<-para1_answer[,.SD[1], by=.(interview__id, role)]
  para1_answer_merge<-para1_answer_merge[ ,.(interview__id, responsible, role)]
  
  ##  2. GPS extract -->if no name, try identification through grepl
  varNames<-levels(para1_answer$var)
  if(is.na(gpsVarName)) {
    if(nrow(qgps)>0) {
      if(interactive()){
        cli::cli_alert_info('The following GPS questions have been identified: {paste(qgps$VariableName, collapse = ", ")}\n')
        cli::cli_alert_warning('Using {qgps$VariableName[1]} for coordinates, if you want to use a different one, please
                             use gpsVarName argument.\n')
      }
      gpsVarMain<-qgps$VariableName[1]
      
    } else {
      if(interactive()){
        cli::cli_alert_danger('No GPS questions have been identified. Proceeding without GPS.\n')
      }
      gpsVarMain<-character(0)
    }
  } else {
    #stopifnot(is.character(gpsVarName), gpsVarName %in% varNames)
    if(!(gpsVarName %in% qgps$VariableName)) {
      cli::cli_alert_danger('The GPS variable you have selected is not in the questionnaire. Proceeding without GPS.\n')
      gpsVarMain<-character(0)
    } else {
      gpsVarMain<-gpsVarName[1]
    }
  }
  
  ## create gps file when exists
  if (length(gpsVarMain)>0) {
    ## Select first gps variable
    cli::cli_alert_info("\nExtracting GPS variable for all data.\n")
    gpsVar<-gpsVarMain[1]
    gps_file<-para1_answer[var==gpsVar]
    if(nrow(gps_file)==0) {
      cli::cli_alert_danger("No GPS data found with: {gpsVar}.")
      ##  IF NO GPS AVAILABLE
      gps_file_merge<-data.table(interview__id = "a0", lat = 0, long = 0)
      #gps_file_merge<-gps_file_merge[,.SD[1], by=.(interview__id)]
      setkeyv(gps_file_merge, "interview__id")
    } else {
      if (!allResponses) {
        gp<-gps_file[,tstrsplit(response, ",", fixed=TRUE, fill = "<NA>", names = TRUE)][]
        gps_file<-cbind(gps_file, gp)
        setnames(gps_file, c("V1", "V2"), c("response1", "response2"))
      }
      
      gps_file<-gps_file[, .(interview__id, responsible, time, var_resp, var,
                             date, durationNOBREAK, response1, response2)]
      gps_file<-gps_file[,c("long"):=tstrsplit(response2, "[", fixed=TRUE ,keep=c(1))][]
      gps_file[,lat:=as.numeric(as.character(response1))]
      gps_file[,long:=as.numeric(as.character(long))]
      gpsSelect<-sum(!is.na(gps_file$lat))
      ## If empty iterate over next/only if length>1/until length==k
      k<-2
      while(gpsSelect>=0 & gpsSelect<=nrow(gps_file) & length(gpsVarMain) >1 & length(gpsVarMain) != k) {
        gpsVar<-gpsVarMain[k]
        gps_file<-para1_answer[var==gpsVar]
        if (!allResponses) {
          gp<-gps_file[,tstrsplit(response, ",", fixed=TRUE, fill = "<NA>", names = TRUE)][]
          gps_file<-cbind(gps_file, gp)
          setnames(gps_file, c("V1", "V2"), c("response1", "response2"))
        }
        gps_file<-gps_file[, .(interview__id, responsible, time, var_resp,
                               date, durationNOBREAK, response1, response2)]
        gps_file<-gps_file[,c("long"):=tstrsplit(response2, "[", fixed=TRUE ,keep=c(1))][]
        gps_file[,lat:=as.numeric(as.character(response1))]
        gps_file[,long:=as.numeric(as.character(long))]
        k<-k+1
        gpsSelect<-sum(!is.na(gps_file$lat))
      }
      ##  For merge with EVENT data
      gps_file_merge<-gps_file[,.(interview__id, lat, long)]
      gps_file_merge<-gps_file_merge[,.SD[1], by=.(interview__id)]
      setkeyv(gps_file_merge, "interview__id")
    }
  } else if(length(gpsVarMain)==0) {
    ##  IF NO GPS AVAILABLE
    gps_file_merge<-data.table(interview__id = "a0", lat = 0, long = 0)
    #gps_file_merge<-gps_file_merge[,.SD[1], by=.(interview__id)]
    setkeyv(gps_file_merge, "interview__id")
  }
  ##  Subset with function, key and lapply
  ## loop over levels of action with LAPPLY
  ## a<-lapply(levels(CHECK$action), FUN = subsetDataTableAction, CHECK)
  ##  not used for now
  subsetDataTableAction<-function(dt, x) {
    setkeyv(x, "action")
    file<-x[dt]
    return(file)
  }
  
  # get number of processes
  simu<-length(levels(droplevels(paradata_files$action)))
  
  if (is.null(multiCore)) {
    progressr::handler_cli()
    if(!(shiny::isRunning())){
      # progressr::handlers(global = T)
      # on.exit(progressr::handlers(global = F))
      
      progressr::with_progress({
        p<-progressr::progressor(along = 1:simu)
        para_data <- .process_para_foreach(simu = simu, para_data = para_data,
                                           prog = p, #pack_dp_sp = pack_dp_sp,
                                           paradata_files = paradata_files,
                                           gps_file_merge = gps_file_merge,
                                           para1_answer_merge = para1_answer_merge,
                                           KeyAssigned_merge  = KeyAssigned_merge,
                                           onlyActiveEvents = onlyActiveEvents,
                                           para1_answer = para1_answer,
                                           parallel = FALSE)
        
      })
    }
    para_data[["actionDistr"]]<-actionDistr
    para_data[["userDistr"]]<-userDistr
    para_data[["roleDistr"]]<-roleDistr
    if(verbose) message("Export & Transformation finished.")
    
  } else if(is.numeric(multiCore) && multiCore>1) {
    ###############################
    ## MULTICORE:
    # check for package and ask for install
    rlang::check_installed(
      c("doFuture", "future"),
      reason = "The doFuture and future packages are required for parallel processing of paradata."
    )
    # get required cores, one for each action
    simu<-length(levels(droplevels(paradata_files$action)))
    # SET to 16gb for future parallel (probably later modify w option)
    sizeRamMB<-floor(.detectTotalMemory())
    options(future.globals.maxSize=sizeRamMB*1024^2)
    ncores<-getOption("suso.para.maxcore")
    multiCore <- min(simu, ncores)
    if(verbose) message("Starting Multicore with: ", multiCore, " cores.")
    
    # launching the future backend
    # get the options
    oplan<-future::plan("multisession")
    on.exit(future::plan(oplan))
    nplan<-getOption("suso.para.plan")
    # get current state and reset on exit as recommended
    # in registerDoFuture documentatin
    oldDoPar <- doFuture::registerDoFuture()
    on.exit(with(oldDoPar, foreach::setDoPar(fun=fun, data=data, info=info)), add = TRUE)
    # Current loop
    doFuture::registerDoFuture()
    if(nplan=="sequential") {
      #  with workers gives warning
      future::plan(nplan)
    } else {
      # maxCore retires
      future::plan(nplan, workers = multiCore)
    }
    progressr::handler_cli()
    # if(!(shiny::isRunning())){
    #   progressr::handlers(global = T)
    #   on.exit(progressr::handlers(global = F))
    # }
    
    # for non-shiny
    if(!(shiny::isRunning())){
      progressr::with_progress({
        p<-progressr::progressor(along = 1:simu)
        withr::with_options(
          list(future.globals.onReference = NULL),
          para_data <- .process_para_foreach(simu = simu, para_data = para_data,
                                             prog = p, #pack_dp_sp = pack_dp_sp,
                                             paradata_files = paradata_files,
                                             gps_file_merge = gps_file_merge,
                                             para1_answer_merge = para1_answer_merge,
                                             KeyAssigned_merge  = KeyAssigned_merge,
                                             onlyActiveEvents = onlyActiveEvents,
                                             para1_answer = para1_answer)
        )
      })
    } else {
      progressr::withProgressShiny(
        message = "Processing paradata",
        detail = "This may take a while ...",
        value = 0, {
          p<-progressr::progressor(along = 1:simu)
          withr::with_options(
            list(future.globals.onReference = NULL),
            para_data <- .process_para_foreach(simu = simu, para_data = para_data,
                                               prog = p, #pack_dp_sp = pack_dp_sp,
                                               paradata_files = paradata_files,
                                               gps_file_merge = gps_file_merge,
                                               para1_answer_merge = para1_answer_merge,
                                               KeyAssigned_merge  = KeyAssigned_merge,
                                               onlyActiveEvents = onlyActiveEvents,
                                               para1_answer = para1_answer)
          )
        })
    }
    # add action count summary tables
    para_data[["actionDistr"]]<-actionDistr
    para_data[["userDistr"]]<-userDistr
    para_data[["roleDistr"]]<-roleDistr
  } else {
    cli::cli_abort(c("x" = "If multiCore is not NULL, it must be numeric and greater 1. Please check your inputs!"))
  }
  
  # return list or exportClass data.table
  if(!onlyActiveEvents | asList) {
    return(para_data)
  } else if(onlyActiveEvents && !asList) {
    cli::cli_alert_info("Processing single dataframe object.")
    # list for paradata to be handed to exportClass
    para_data_all<-list()
    pdmain<-data.table::rbindlist(para_data[c("AnswerSet", "AnswerRemoved", "Restarted")], fill = TRUE)
    # adjust names to match suso
    setnames(pdmain,
             old = c("var", "key"),
             new = c("VariableName", "interview__key")
    )
    # remove redundant columns & !!!TD:  MOVE DURATION ETC TO ATTRIBUTES ADD SECTION TITLE
    pdmain[,c("var_resp", "rid"):=NULL][]
    # para_data<-para_data[allquestions[,.(VariableName, type, QuestionText, Featured)], on="VariableName"]
    # para_data <- merge(para_data, allquestions[,.(VariableName, type, QuestionText, Featured)], all.x = T)
    
    # set key for index
    setkeyv(pdmain, c("interview__id", "counter"))
    para_data_all[["paradata"]]<-pdmain
    
    # get other elements already calculated
    para_data_all[["action"]]<-para_data[["actionDistr"]]
    para_data_all[["user"]]<-para_data[["userDistr"]]
    para_data_all[["role"]]<-para_data[["roleDistr"]]
    rm(para_data); gc()
    
    
    # add to export class
    # bbb[VariableName!= "<NA>",.(av_response_time=mean(resp_time)), by=.(VariableName)]
    # bbb[VariableName!= "<NA>",.(int_duration=sum(resp_time, na.rm = T)/60), by=.(interview__id)]
    # bbb[type!= "<NA>",.(av_resp_time=sum(resp_time, na.rm = T)/60), by=.(type)]
    
    # convert to export class
    para_data_all<-exportClass(para_data_all, NULL, args)
    return(para_data_all)
    
  }
  
  
  
  ############################  FINFINFIN   #####################################
}
