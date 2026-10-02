# Assign interview to interviewer or supervisor

Reassigns an interview to a specified interviewer or supervisor.

## Usage

``` r
suso_assignInterview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = "",
  userId = NULL,
  userName = NULL,
  supervisor = FALSE
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

  server workspace name

- token:

  API token

- intID:

  InterviewId (GUID)

- userId:

  User GUID of responsible person

- userName:

  Name of responsible person (optional)

- supervisor:

  If TRUE assigns to a supervisor, otherwise assigns to an interviewer

## Value

A data.table indicating the assignment status.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_assignInterview(
  intID = "11111111-2222-3333-4444-555555555555",
  userName = "interviewer01"
)
} # }
```
