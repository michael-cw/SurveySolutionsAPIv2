#' Paradata helper functions
#'
#' The functions bellow are used to process paradata.
#'
#'
#' @keywords internal
#' @noRd
#'

.export_remove_na_columns <- function(dt) {

  # integers to remove
  intcols<-which(sapply(dt, function(x) is.integer(x) & all(x == -999999999L)))
  if(length(intcols)>0) dt[, (intcols) := NULL]
  # characters to remove
  charcols<-which(sapply(dt, function(x) !lubridate::is.POSIXt(x)  && is.character(x) && all(x == "##N/A##")))
  if(length(charcols)>0) dt[, (charcols) := NULL]

  return(dt)
}



#' Response Time
#'
#' @noRd
#' @keywords internal
#'

.calcTimeDiff<-function(DTfile, by=c("interview__id","DAY", "MONTH")){
  DTfile<-copy(DTfile)
  setorderv(DTfile, c("interview__id","date", "time", "counter"))
  #DTfile<-DTfile[,.SD[.N>20], by=.(interview__id)]
  # DTfile[,resp_time:=as.numeric(0.000)][ ,resp_time:=fifelse((data.table::shift(date, type = "lag")==date & action!="Paused"),
  #                                                        as.numeric(time-data.table::shift(time, type = "lag")), 0.000), by=.(interview__id)][]
  DTfile[,resp_time:=as.numeric(0.000)][ ,resp_time:=fifelse((data.table::shift(date, type = "lag")==date & action!="Paused"),
                                                             as.numeric(dateTime-data.table::shift(dateTime, type = "lag")), 0.000), by=.(interview__id)][]
  DTfile[, breaks:=fifelse(resp_time>120&!is.na(resp_time),1L,0L), by=.(interview__id)]
  return(DTfile)
}
#' Unpack
#' @noRd
#' @keywords internal
#'
.unpack<-function(fp, allResponses, inShinyServer){
  ####################################################
  ##  1. Use fread from data.table (fastest, needs to be tested for reliability)
  HEADER<-c("interview__id", "counter", "action", "responsible", "role", "time", "tz","var_resp")
  file<-fread(file=fp,
              header = TRUE,
              data.table = TRUE,
              #col.names = HEADER,
              fill = TRUE,sep = "\t",
              colClasses = list(character=c(1,3:8),
                                numeric=c(2)),
              blank.lines.skip=TRUE,
              encoding = "UTF-8")
  names(file)<-HEADER
  ## check lines
  if(nrow(file)==0) return(NULL)
  ## message if large file
  if(nrow(file)>100000) message("There are ", nrow(file), " individual events. Processing may take a while!")
  ## splitting response variable
  #names(file)<-
  ## Exract the VARIABLENAME
  resps<-file[,tstrsplit(var_resp, "||", fixed=TRUE, names = TRUE, fill = "<NA>")][]
  file[,var:=resps[,.(V1)]]
  if (allResponses) {
    ## Extract all responses if TRUE
    resps1<-resps[,tstrsplit(V2, "(\\|)|(,)", fixed=FALSE, names = TRUE, fill = "<NA>")][]
    file[,c(paste0("response", 1:(length(resps1)))):=resps1]
    splits <- (length(resps1))
    # Check if V3 exists in names
    if("V3" %in% names(resps)){
      resps2<-resps[,tstrsplit(V3, "(,)", fixed=FALSE, names = TRUE, fill = "<NA>")][]
      file[,c(paste0("rid", 1:(length(resps2)))):=resps2]
    }
  } else {
    ## Extract only single vector-->FASTER
    file[,response:=resps[,.(V2)]]
  }

  if(inShinyServer) incProgress(amount = 0.25, message = "Data loaded")
  if (nrow(file)==0) return(NULL)
  ####################################################
  ##  3. Create Factors
  #file[,interview__id:=as.factor(interview__id)]
  file[,action:=as.factor(action)]
  file[,responsible:=as.factor(responsible)]
  file[,role:=as.factor(role)]
  #file[,var:=as.factor(var)]
  ## only with all responses factorization of response
  if (allResponses) {
    for (i in 1:splits) {
      ip<-paste0("response", (i))
      file[,c(ip):=as.factor(get(ip))]
    }
  }

  ##  4. DATE is adjusted for timezone!
  ##      !!!! IMPORTANT: TIME STAMPS ARE IN UTC, TAKE TZ FOR LOCAL
  ##      !!!! TZ is negative therefor +
  file[,dateTimeUTC:=lubridate::as_datetime(time, tz = "UTC")]
  ## Date time uses system local tz, needs to be changed in options
  file[,dateTime:=lubridate::as_datetime(time, tz = getOption("suso.para.tz")) + lubridate::hms(tz)][,c("tz"):=NULL]
  # file[,timeChr:=paste(time, str_remove(tz, ":00$"))]
  file[,time:=as.ITime(dateTime)]
  file[,date:=as.IDate(dateTime)]
  file[,wDAY:=wday(date)]
  file[,mDAY:=mday(date)]
  file[,MONTH:=month(date)]
  file[,WEEK:=isoweek(date)][]
  setkeyv(file, c("interview__id", "responsible"))
  return(file)
  # prog<-prog+1
}


#' Para processing
#'
#'
#' @noRd
#' @keywords internal
#'
.process_para_foreach<-function(..., parallel = TRUE){
  args<-rlang::list2(...)
  simu<-args$simu
  p<-args$prog
  paradata_files<-args$paradata_files
  gps_file_merge<-args$gps_file_merge
  para1_answer_merge<-args$para1_answer_merge
  para_data<-args$para_data
  KeyAssigned_merge  = args$KeyAssigned_merge
  onlyActiveEvents = args$onlyActiveEvents
  para1_answer = args$para1_answer

  # solution from:
  # https://stackoverflow.com/questions/43733271/
  # how-to-switch-programmatically-between-do-and-dopar-in-foreach
  `%doselect%` <-ifelse(parallel, `%dopar%`, `%do%`)
  para_data<-foreach(i=1:simu, #.packages = pack_dp_sp,
                     .combine=c,
                     .multicombine = TRUE,
                     .export = c("para_data"),
                     #.verbose = T,
                     .errorhandling="pass") %doselect% {

                       ## progress
                       #p(sprintf("event = %g", event))
                       event<-levels(paradata_files$action)[i]
                       p(sprintf("i=%g", i))
                       if (event=="AnswerSet"){
                         AnswerSet<-para1_answer
                         AnswerSet<-AnswerSet[!is.na(interview__id)]
                         setkeyv(AnswerSet, "interview__id")
                         if(exists("gps_file_merge"))  AnswerSet<-gps_file_merge[AnswerSet, on="interview__id"]
                         AnswerSet<-KeyAssigned_merge[AnswerSet, on="interview__id"]
                         para_data[[event]]<-AnswerSet
                         rm(AnswerSet)

                       } else if (event=="AnswerRemoved"){
                         ##  2.9. Answer Removed (COUNT the number of Removed answer by questionnaire)
                         AnswerRemoved<-paradata_files[action=="AnswerRemoved"]
                         AnswerRemoved<-AnswerRemoved[!is.na(interview__id)]
                         AnswerRemoved[, count:=length(counter), by=interview__id]
                         AnswerRemoved[,c("responsible", "role"):=NULL]
                         AnswerRemoved<-droplevels(AnswerRemoved)
                         AnswerRemoved<-merge(AnswerRemoved, para1_answer_merge, by="interview__id", allow.cartesian=TRUE)
                         setkeyv(AnswerRemoved, "interview__id")
                         if(exists("gps_file_merge")) AnswerRemoved<-gps_file_merge[AnswerRemoved, on="interview__id"]
                         AnswerRemoved<-KeyAssigned_merge[AnswerRemoved, on="interview__id"]
                         para_data[[event]]<-AnswerRemoved
                         rm(AnswerRemoved)
                       } else if (event=="ApproveByHeadquarter") {
                         ##  2.10. Approved
                         ApproveByHeadquarter<-paradata_files[action=="ApproveByHeadquarter"]
                         ApproveByHeadquarter<-droplevels(ApproveByHeadquarter)
                         ApproveBySupervisor<-paradata_files[action=="ApproveBySupervisor"]
                         ApproveBySupervisor<-droplevels(ApproveBySupervisor)
                         para_data[[event]]<-ApproveBySupervisor
                         rm(ApproveBySupervisor)
                       } else if (event=="QuestionDeclaredInvalid" & !onlyActiveEvents) {
                         ##  2.11. Invalid
                         QuestionDeclaredInvalid<-paradata_files[action=="QuestionDeclaredInvalid"]
                         QuestionDeclaredInvalid<-QuestionDeclaredInvalid[!is.na(interview__id)]
                         QuestionDeclaredInvalid[, count:=length(counter), by=interview__id]
                         setkeyv(QuestionDeclaredInvalid, "interview__id")
                         if(exists("gps_file_merge")) QuestionDeclaredInvalid<-gps_file_merge[QuestionDeclaredInvalid, on="interview__id"]
                         QuestionDeclaredInvalid<-KeyAssigned_merge[QuestionDeclaredInvalid, on="interview__id"]
                         para_data[[event]]<-QuestionDeclaredInvalid
                         rm(QuestionDeclaredInvalid)
                       } else if (event=="QuestionDeclaredValid" & !onlyActiveEvents) {
                         ##  2.12. Valid
                         QuestionDeclaredValid<-paradata_files[action=="QuestionDeclaredValid"]
                         QuestionDeclaredValid<-QuestionDeclaredValid[!is.na(interview__id),]
                         QuestionDeclaredValid[, count:=length(counter), by=interview__id]
                         para_data[[event]]<-QuestionDeclaredValid
                         rm(QuestionDeclaredValid)
                       } else if (event=="Restarted") {
                         ##  2.13 Restarted
                         Restarted<-paradata_files[action=="Restarted"]
                         Restarted<-Restarted[!is.na(interview__id),]
                         Restarted[, count:=length(counter), by=interview__id]
                         setkeyv(Restarted, "interview__id")
                         if(exists("gps_file_merge")) Restarted<-gps_file_merge[Restarted, on="interview__id"]
                         Restarted<-KeyAssigned_merge[Restarted, on="interview__id"]
                         para_data[[event]]<-Restarted
                         rm(Restarted)
                       } else if (event=="Reject") {
                         ##  2.14. Rejected
                         Reject<-paradata_files[action=="RejectedBySupervisor"|action=="RejectedByHeadquarter"][,c("var_resp", "rid"):=NULL]
                         setnames(Reject, "var", "comment")
                         Reject<-droplevels(Reject)
                         #paradata_files<-paradata_files[action!="RejectedBySupervisor"&action!="RejectedByHeadquarter"]
                         #paradata_files<-droplevels(paradata_files)
                         setkeyv(Reject, "interview__id")
                         if(exists("gps_file_merge")) Reject<-gps_file_merge[Reject, on="interview__id"]
                         Reject<-KeyAssigned_merge[Reject, on="interview__id"]
                         para_data[[event]]<-Reject
                         rm(Reject)
                       }
                       return(para_data)
                     }

  return(para_data)

}
