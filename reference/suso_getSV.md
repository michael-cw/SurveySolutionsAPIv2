# Survey Solutions API call for list of supervisors

Gets list of supervisors

## Usage

``` r
suso_getSV(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
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

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace, if no workspace is provided defaults to primary workspace.

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

## Value

An object of class `UserClass` (inheriting from data.table) containing
the list of supervisors.

## Examples

``` r
if (FALSE) { # \dontrun{
# receive all supervisors in the workspace
suso_getSV()
} # }
```
