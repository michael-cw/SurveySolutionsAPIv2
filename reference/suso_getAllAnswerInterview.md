# Survey Solutions API call to retrieve all answers for a specific interview

Returns all responses for a specific interview

## Usage

``` r
suso_getAllAnswerInterview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = ""
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

- intID:

  the *InterviewId* of the interview. To get a list of all interview for
  a specific questionnaire, execute `suso_getAllInterviewQuestionnaire`

## Value

A data.table containing all answers for the given interview.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getAllAnswerInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
          )

} # }
```
