# Survey Solutions API call for supervisor info

Gets detailed info about a single supervisor by supervisor ID.

## Usage

``` r
suso_getSV_info(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  sv_id = NULL,
  workspace = suso_get_api_key("workspace"),
  token = NULL
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- sv_id:

  supervisor ID (GUID)

- workspace:

  server workspace name

- token:

  API token

## Value

A data.table containing supervisor details.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getSV_info(
  workspace = "myworkspace",
  sv_id = "xxxx-xxxx-xxxx-xxx"
)
} # }
```
