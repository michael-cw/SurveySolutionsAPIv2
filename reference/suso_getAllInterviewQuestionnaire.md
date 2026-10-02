# Survey Solutions API call to retrieve all interviews for a specific questionnaire

Returns all interviews for the specified questionnaire and the selected
status.

## Usage

``` r
suso_getAllInterviewQuestionnaire(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = "",
  version = 1,
  workStatus = c("Completed", "All", "SupervisorAssigned", "InterviewerAssigned",
    "RejectedBySupervisor", "ApprovedBySupervisor", "RejectedByHeadquarters",
    "ApprovedByHeadquarters")
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

  your Survey Solutions *QuestionnaireId*. Retrieve a list of
  questionnaires by executing `suso_getQuestDetails`

- version:

  version of the questionnaire

- workStatus:

  define which statuses the file should inlude (i.e.
  *Restored,Created,SupervisorAssigned,InterviewerAssigned,
  RejectedBySupervisor,ReadyForInterview,
  SentToCapi,Restarted,Completed,ApprovedBySupervisor,
  RejectedByHeadquarters,ApprovedByHeadquarters,Deleted*), if NULL only
  completed interviews will be shown.

## Value

A data.table listing all interviews matching the specified questionnaire
and status filter.

## Details

ATTENTION: This function only exists for consistency reasons with the
original SurveySolutionsAPI package. Under the hood it uses
[`suso_getQuestDetails`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getQuestDetails.md),
which is based on the GraphQL API.

## Examples
