#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import data.table
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table :=
#' @import httr2
#' @rawNamespace import(rlang, except = c(`:=`, unbox))
#' @importFrom dplyr bind_rows select_if union
#' @importFrom graphics boxplot
# #' @importFrom httr authenticate build_url GET parse_url
#' @importFrom jsonlite fromJSON unbox
#' @importFrom stats setNames sd as.formula
#' @importFrom lubridate as_datetime ymd ymd_hms now today hms
#' @importFrom stringr str_count str_detect str_extract str_replace_all str_split str_sub str_remove
#' @importFrom tidyjson enter_object gather_array spread_all jstring jnumber jlogical bind_rows spread_values
#' @importFrom zip unzip
#' @importFrom utils setTxtProgressBar txtProgressBar
#' @importFrom foreach foreach %dopar% %do%
## usethis namespace: end
NULL


## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "3.3.0")  {
  utils::globalVariables(c(
    ".", "i", "Quantity", "ResponsibleName", "type",
    "LinkType", "L0", "L1", "L2", "L3", "L4", "Title", "PublicKey",
    "AnswerValue", "..JSON", "Rsize", "Rtype", "RsizeKey", "Rvar",
    "RvarMerge", "parentid1", "parentid2", "parentgroup", "pargroupcount",
    "HasExportFile", "JobId", "StartDate", "ReceivedByDeviceAtUtc",
    "variable", "value", "Role", "UserName", "FullName", "Password",
    "Supervisor", "PhoneNumber", "Featured", "type1", "isFixeRoster",
    "QuestionText", "translations", "Version", "Completed", "Assigned",
    "resp_time",
    "action",
    "time",
    "interview__id",
    "breaks",
    "test_detail",
    "UPLOADdataCHECK",
    "QuestionnaireIdentity",
    "Variable",
    "action",
    "setNames",
    "incProgress",
    "rid",
    "duration",
    "durationNOBREAK",
    "m_resp_time_varTRIM",
    "var",
    "start",
    "startHour",
    "responsible",
    "m_resp_time_var",
    "m_diff_dev",
    "response",
    "var_resp",
    "response1",
    "response2",
    "resps",
    "lat",
    "long",
    "count",
    "counter",
    "handlers",
    "Timestamp",
    "LastEntryDate",
    "CreationDate",
    "document.id",
    "var_resp", "V1", "V2", "V3",
    "response",
    "responsible",
    "role",
    "dateTime", "dateTimeUTC","tz","wDAY","mDAY","MONTH", "WEEK",
    "UpdatedAtUtc", "InterviewDuration", "intID",
    "VariableName", "Expression", "Message", "Severity",
    "QuestionnaireId", "StartDate", "CompleteDate", "pid",
    "ExportType", "Time", "importDateUtc", "CreatedAtUtc",
    "ReceivedByTabletAtUtc", "GeometryType"
  ))
}
