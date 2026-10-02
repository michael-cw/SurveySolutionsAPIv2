# Leave a comment on a question in an interview

Leaves a comment on a question using either the questionId or the
questionnaire variable name.

## Usage

``` r
suso_commentInterview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = "",
  comment = "",
  questionId = NULL,
  variable = NULL,
  rosterVector = NULL
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

- comment:

  The comment text to leave

- questionId:

  The question GUID (optional if variable is provided)

- variable:

  Variable name of question (optional if questionId is provided)

- rosterVector:

  Integer vector specifying roster indices (e.g. c(0, 1))

## Value

A data.table indicating the comment status.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_commentInterview(
  intID = "11111111-2222-3333-4444-555555555555",
  variable = "age",
  comment = "Please verify respondent age."
)
} # }
```
