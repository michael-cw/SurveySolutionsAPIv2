# Survey Solutions API call for assignment list

`suso_get_assignments` calls the Survey Solutions assignment API

## Usage

``` r
suso_get_assignments(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  questID = NULL,
  AssId = NULL,
  version = NULL,
  responsibleID = NULL,
  supervisorId = NULL,
  searchBy = NULL,
  status = NULL,
  start = NULL,
  length = NULL,
  ShowArchive = FALSE,
  order.by = c("Id ASC", "Id DESC", "ResponsibleName DESC", "ResponsibleName ASC",
    "InterviewsCount DESC", "InterviewsCount ASC", "Quantity DESC", "Quantity ASC",
    "UpdatedAtUtc DESC", "UpdatedAtUtc ASC", "CreatedAtUtc DESC", "CreatedAtUtc ASC"),
  operations.type = c("assignmentQuantitySettings", "history", "recordAudio")
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace

- questID:

  only assignments for *QuestionnaireId* are returned, requires
  `version` being not NULL

- AssId:

  if NULL a list of all assignments on the server, if not NULL the
  assignment details for a specific assignment ID

- version:

  version of the questionnaire, only required with `questID`

- responsibleID:

  the ID of the responsible user (Supervisor or Interviewer). Retrieves
  all assignments for this user.

- supervisorId:

  Filter assignments by supervisor ID

- searchBy:

  Filter result by custom search query

- status:

  Filter assignments by status (e.g. NotAssigned, Assigned, Closed,
  Archived, Deleted, Completed)

- start:

  start index for history query (only with operations.type = "history")

- length:

  page length for history query (only with operations.type = "history")

- ShowArchive:

  if TRUE, only archived assignments are included in the list

- order.by:

  determines the column by which the assignment list should be ordered,
  one of *Id*, *ResponsibleName*, *InterviewsCount*, *Quantity*,
  *UpdatedAtUtc*, *CreatedAtUtc*, followed by ordering direction "ASC"
  or "DESC", e.g. "Id DESC" or "CreatedAtUtc ASC"

- operations.type:

  specifies the desired operation, one of assignmentQuantitySettings,
  history, or recordAudio, if specified, requires also *AssId* to be
  specified.

## Value

Returns an S3 object of assignmentClass. If you select any of the
operations types, then no data.frame is returned, the data.table will be
NULL, however any information returned from the API can be retrieved by
using the
[`getinfo()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/getinfo.md)
function with the corresponding arguments.

## Examples
