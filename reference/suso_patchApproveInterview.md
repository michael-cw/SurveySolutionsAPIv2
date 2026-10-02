# Approve interviews either as supervisor or as headquarter.

Allows you to approve interviews in supervisor or headquarters role,
unapprove from headquarters status, as well as to provide a comment
(i.e. reason).

## Usage

``` r
suso_patchApproveInterview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = "",
  HQ = FALSE,
  hqunapprove = FALSE,
  comment = "Well done!"
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

  the *InterviewId* of the interview.

- HQ:

  if FALSE, approve as supervisor, if TRUE approve as headquarters

- hqunapprove:

  if TRUE, unapprove from headquarters status (hqunapprove)

- comment:

  comment which should be sent with the questionnaire

## Value

A data.table containing the status of the approval operation.

## Details

For details please see:
<https://docs.mysurvey.solutions/headquarters/interviews/survey-workflow/>

## Examples

``` r
if (FALSE) { # \dontrun{
# approve the interview as supervisor
suso_patchApproveInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
          )
# approve the interview as headquarters
suso_patchApproveInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
          HQ = TRUE
          )
} # }
```
