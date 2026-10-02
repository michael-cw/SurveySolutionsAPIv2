#' Upload map to server
#'
#' Allows the user to upload a zip file of background maps and boundary files
#'
#' @details Resources for upload must meet the requirements specified under:
#' \url{https://docs.mysurvey.solutions/headquarters/mapsmanage/map-formats/},
#' Attention: this uses the GraphQL API, not the REST API.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param path_to_zip either path to zip file or directory of files which will automatically be zipped as required
#'
#' @return Returns a data.table, with information about the uploaded maps
#'
#' @examples
#' \dontrun{
#' # either upload the content of a folder
#' suso_mapupload(workspace = "myworkspace",
#'               path_to_zip = "./mapfiles/")
#'
#' # or a zip file with the files included
#' suso_mapupload(workspace = "myworkspace",
#'               path_to_zip = "../mapfiles/maps.zip")
#' }
#'
#'
#'
#'
#' @export


suso_mapupload <- function(server= suso_get_api_key("susoServer"),
                           apiUser=suso_get_api_key("susoUser"),
                           apiPass=suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           path_to_zip = NULL) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  if(is.null(path_to_zip)) cli::cli_abort(c("x" = "Please provide a a file or directory path."))

  fi<-file.info(path_to_zip)
  if(fi$isdir) {
    # directory to zip in temporary
    fl<-list.files(path_to_zip,
                   pattern = "(.shp)|(.shx)|(.dbf)|(.prj)|(.tpk)|(.tif)|(.tiff)|(.mmpk)",
                   full.names = T)
    tmpzip<-tempfile(fileext = ".zip")
    zip::zip(tmpzip, files = fl, mode = "cherry-pick")
    path_to_zip<-tmpzip

  } else if(!fi$isdir && tools::file_ext(path_to_zip)=="zip") {
    #path_to_zip

  } else {
    cli::cli_abort(c("x" = "File is neither a directory nor a .zip file"))
  }

  result<-susographql::suso_gql_uploadmap(
    endpoint = paste0(server, "graphql"),
    workspace = workspace,
    user = apiUser,
    password = apiPass,
    path_to_zip = path_to_zip
  )
  result<-data.table::data.table(result$uploadMap)
  if(nrow(result)>0) result[,importDateUtc:=lubridate::as_datetime(importDateUtc)][]
  return(result)
}


#' Receive maps currently uploaded to the server
#'
#' Allows the user to retrieve filtered or unfiltered map data inlcuding map details, like size, assigned users etc..
#'
#' @details Attention: this uses the GraphQL API, not the REST API.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param fileName name of the map on the server
#' @param importDateUtc Import date
#' @param size Size of the map
#' @param users Users to whom the maps are assigned
#' @param sortby_filename sort maps by file name, either ASC for ascending or DESC for descending
#' @param sortby_importeddateutc sort maps by import date in utc, either ASC for ascending or DESC for descending
#' @param sortby_size sort by map size, either ASC for ascending or DESC for descending
#' @param take take the specified integer numeber of maps
#' @param skip skip the first integer number of maps
#'
#' @return Returns a data.table, with all the maps and additonal information. If multiple users are assigned to a map,
#' the table is expanded, such that there is one user per map.
#'
#' @examples
#' \dontrun{
#' suso_mapinfo(workspace = "myworkspace")
#' }
#'
#' @export

suso_mapinfo <- function(server= suso_get_api_key("susoServer"),
                         apiUser=suso_get_api_key("susoUser"),
                         apiPass=suso_get_api_key("susoPass"),
                         workspace = suso_get_api_key("workspace"),
                         token = NULL,
                         fileName = NULL,
                         importDateUtc = NULL,
                         size = NULL,
                         users = NULL,
                         sortby_filename = NULL,
                         sortby_importeddateutc = NULL,
                         sortby_size = NULL,
                         take = NULL,
                         skip = NULL) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)

  result<-susographql::suso_gql_maps(
    endpoint = paste0(server, "graphql"),
    workspace = workspace,
    user = apiUser,
    password = apiPass
  )

  tc<-result$maps$totalCount
  fc<-result$maps$filteredCount

  if(fc>0){
    rc<-nrow(result$maps$nodes)
    resultdt<-result$maps$nodes
    # extract user list with tidyr::unnest
    resultdt<-tidyr::unnest(resultdt, "users", keep_empty = T)

    # create data.table
    resultdt<-data.table::data.table(resultdt)
    if(nrow(resultdt)>0) {
      #resultdt[, users:=gsub("c\\(|\\)", "",sapply(users, paste, collapse=""))]
      resultdt[,importDateUtc:=lubridate::as_datetime(importDateUtc)][]
    }
  } else if(fc==0) {
    resultdt<-data.table(NULL)
  }

  return(resultdt)

}

#' Assigns/Unassign a map to a user
#'
#' Allows the user to assign/unassign a map to an interviewer to be used in CAPI data collection.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param fileName the name of the map file on the server
#' @param userName the name of the interviewer to whom the map will be assigned to
#' @param assignUser if TRUE user will be assigned to map, if FALSE user will be removed from map
#'
#'
#' @examples
#' \dontrun{
#' suso_mapassign(workspace = "myworkspace",
#'               fileName = "Lat9264Lon625_ALL.tif",
#'               userName = "INT0004")
#' }
#'
#' @return A data.table containing the map assignment details (file name, user name, shape type, and import timestamp).
#' @export


suso_mapassign <- function(server= suso_get_api_key("susoServer"),
                           apiUser=suso_get_api_key("susoUser"),
                           apiPass=suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           fileName = NULL,
                           userName = NULL,
                           assignUser = TRUE) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)


  # assign
  if(assignUser) {
    result<-susographql::suso_gql_addusertomap(
      endpoint = paste0(server, "graphql"),
      workspace = workspace,
      user = apiUser,
      password = apiPass,
      fileName = fileName,
      userName = userName
    )

    result<-result$addUserToMap
    result<-data.table::data.table(
      fileName=result$fileName,
      user=userName,
      shapeType=result$shapeType,
      importDateUtc=lubridate::as_datetime(result$importDateUtc)
    )
  } else if(!assignUser) {
    result<-susographql::suso_gql_deleteuserfrommap(
      endpoint = paste0(server, "graphql"),
      workspace = workspace,
      user = apiUser,
      password = apiPass,
      fileName = fileName,
      userName = userName
    )

    result<-result$deleteUserFromMap
    result<-data.table::data.table(
      fileName=result$fileName,
      user=userName,
      shapeType=result$shapeType,
      importDateUtc=lubridate::as_datetime(result$importDateUtc)
    )

  }
  return(result)

}


#' Delete Map from Server
#'
#' Allows the user to delete maps stored on the server.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param fileName the name of the map file on the server
#'
#'
#' @examples
#' \dontrun{
#' suso_deletemap(
#'   workspace = "myworkspace",
#'   fileName = "Lat9264Lon625_ALL.tif"
#' )
#' }
#'
#' @return A data.table containing the deleted map details (file name, shape type, and import timestamp).
#' @export


suso_deletemap <- function(server= suso_get_api_key("susoServer"),
                           apiUser=suso_get_api_key("susoUser"),
                           apiPass=suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           fileName = NULL) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)



  result<-susographql::suso_gql_deletemap(
    endpoint = paste0(server, "graphql"),
    workspace = workspace,
    user = apiUser,
    password = apiPass,
    fileName = fileName
  )

  result<-result$deleteMap
  result<-data.table::data.table(
    fileName=result$fileName,
    shapeType=result$shapeType,
    importDateUtc=lubridate::as_datetime(result$importDateUtc)
  )


  return(result)

}

#' Create a Map Report
#'
#' Allows the user to create a map report with pre-specified parameters.
#'
#' @param server Survey Solutions server address
#' @param apiUser Survey Solutions API user
#' @param apiPass Survey Solutions API password
#' @param workspace server workspace, if nothing provided, defaults to primary
#' @param token If Survey Solutions server token is provided \emph{apiUser} and \emph{apiPass} will be ignored
#' @param questID Questionnaire ID
#' @param version Questionnaire version
#' @param variable Variable(s) of interest
#' @param zoom Zoom of the map report
#' @param clientMapWidth width of the client map
#' @param west coordinates for bounding box
#' @param east coordinates for bounding box
#' @param north coordinates for bounding box
#' @param south coordinates for bounding box
#' @param assignmentId Assignment ID
#' @param clientKey Interview key
#' @param createdDate Creation data of the interview
#' @param errorsCount number of errors
#' @param identifyingData Pre-loaded identifying data
#' @param interviewMode Interview mode (CAWI or CAPI)
#' @param notAnsweredCount number of unanswered questions
#'
#'
#' @examples
#' \dontrun{
#' suso_mapreport(
#'   workspace = "myworkspace",
#'   questID = "11111111-2222-3333-4444-555555555555",
#'   version = 1,
#'   variable = "gps_loc"
#' )
#' }
#'
#' @return A list containing the map report result.
#' @export


suso_mapreport <- function(server= suso_get_api_key("susoServer"),
                           apiUser=suso_get_api_key("susoUser"),
                           apiPass=suso_get_api_key("susoPass"),
                           workspace = suso_get_api_key("workspace"),
                           token = NULL,
                           questID = NULL,
                           version = NULL,
                           variable = NULL,
                           zoom = 1,
                           clientMapWidth = 0,
                           west = -180,
                           east = 180,
                           north = 90,
                           south = -90,
                           assignmentId = NULL,
                           clientKey = NULL,
                           createdDate = NULL,
                           errorsCount = NULL,
                           identifyingData = NULL,
                           interviewMode = NULL,
                           notAnsweredCount = NULL) {

  # workspace default
  workspace<-.ws_default(ws = workspace)

  # check (.helpers.R)
  .check_basics(token, server, apiUser, apiPass)



  result<-susographql::suso_gql_mapreport(
    endpoint = paste0(server, "graphql"),
    workspace = workspace,
    user = apiUser,
    password = apiPass,
    questID = questID,
    version = version,
    zoom = zoom,
    clientMapWidth = clientMapWidth,
    west = west,
    east = east,
    north = north,
    south = south,
    assignmentId = assignmentId,
    clientKey = clientKey,
    createdDate = createdDate,
    errorsCount = errorsCount,
    notAnsweredCount = notAnsweredCount
  )

  result<-result$mapReport
  result<-data.table::data.table(
    fileName=result$fileName,
    shapeType=result$shapeType,
    importDateUtc=lubridate::as_datetime(result$importDateUtc)
  )


  return(result)

}



