# Create a Map Report

Allows the user to create a map report with pre-specified parameters.

## Usage

``` r
suso_mapreport(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
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
  notAnsweredCount = NULL
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- workspace:

  server workspace, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- questID:

  Questionnaire ID

- version:

  Questionnaire version

- variable:

  Variable(s) of interest

- zoom:

  Zoom of the map report

- clientMapWidth:

  width of the client map

- west:

  coordinates for bounding box

- east:

  coordinates for bounding box

- north:

  coordinates for bounding box

- south:

  coordinates for bounding box

- assignmentId:

  Assignment ID

- clientKey:

  Interview key

- createdDate:

  Creation data of the interview

- errorsCount:

  number of errors

- identifyingData:

  Pre-loaded identifying data

- interviewMode:

  Interview mode (CAWI or CAPI)

- notAnsweredCount:

  number of unanswered questions

## Value

A list containing the map report result.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_mapreport(
  workspace = "myworkspace",
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1,
  variable = "gps_loc"
)
} # }
```
