# Survey Solutions API call to get detailed information about an export process

Retrieves status and details of a single export process by its ID.

## Usage

``` r
suso_getExportProcess(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  jobid = NULL
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

  server workspace, if nothing provided, defaults to primary

- jobid:

  Export process ID (integer)

## Value

A data.table containing export process details.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get status of export process by jobid
proc_info <- suso_getExportProcess(jobid = 123)
} # }
```
