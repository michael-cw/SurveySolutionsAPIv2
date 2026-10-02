# Reject interviews either as supervisor or as headquarter.

Allows you to reject interviews in supervisor or headquarters role as
well as to provide a comment (i.e. reason) for the rejection.

## Usage

``` r
suso_patchRejectInterview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = "",
  new_uid = NULL,
  HQ = FALSE,
  comment = "Please check errors and re-submit!"
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

- new_uid:

  if provided the interview will be rejected to a different user than
  the current one.

- HQ:

  if FALSE, reject as supervisor, if TRUE rejected as headquarters

- comment:

  comment which should be sent with the questionnaire

## Value

A data.table containing the status of the rejection operation.

## Details

For details please see:
<https://docs.mysurvey.solutions/headquarters/interviews/survey-workflow/>

## Examples

``` r
if (FALSE) { # \dontrun{
# reject the interview as supervisor
suso_patchRejectInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
          )
# reject the interview as headquarters
suso_patchRejectInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
          HQ = TRUE
          )
# reject the interview and provide a comment, so the interviewer knows about the problem
suso_patchRejectInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
          comment = "Too many errors, please check and re-submit!"
          )
# reject the interview to a different user
suso_patchRejectInterview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea",
          new_uid = "3b0c6e09-d606-4914-9e20-2abc048d5bea"
          )

} # }
```
