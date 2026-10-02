# Survey Solutions API call for info on interviewers

Get details of a single interviewer or retrieve the action log

## Usage

``` r
suso_getINT_info(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  int_id = NULL,
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  log = FALSE,
  startDate = NULL,
  endDate = NULL
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- int_id:

  interviewer id

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace, if no workspace is provided defaults to primary workspace.

- token:

  If Survey Solutions server token is provided *usr* and *pass* will be
  ignored

- log:

  If TRUE, then the audit log is returned

- startDate:

  Start data for the period of interest, date must be provided as
  character in the format: YYYY-MM-DD, and will start at 00:00.00 server
  time of the specified day

- endDate:

  End date for the period of interest, date must be provided ascharacter
  in the format: YYYY-MM-DD, and will end at 23:59:59 server time of the
  specified day. If not end date is provided, the current date will be
  used

## Value

A data.table containing interviewer details or audit logs.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getINT_info(
          workspace = "myworkspace",
          int_id = "xxxx-xxxx-xxxx-xxx"
          )
} # }
```
