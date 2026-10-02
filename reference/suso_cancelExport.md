# Survey Solutions API call to cancel an export process

Cancels an ongoing export process or deletes an export process by ID.

## Usage

``` r
suso_cancelExport(
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

A data.table containing the canceled export process information.

## Examples

``` r
if (FALSE) { # \dontrun{
# Cancel an ongoing export process
suso_cancelExport(jobid = 123)
} # }
```
