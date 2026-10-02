# Delete an interview

Deletes an interview from the Survey Solutions server.

## Usage

``` r
suso_deleteInterview(
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

  server workspace name

- token:

  API token

- intID:

  InterviewId of the interview (GUID)

## Value

A data.table indicating the deletion status.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_deleteInterview(intID = "11111111-2222-3333-4444-555555555555")
} # }
```
