# Update workspace details

Updates the display name of a workspace. Accessible only to
administrator.

## Usage

``` r
suso_updateWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = NULL,
  displayName = NULL
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

  API token

- workspace:

  Name of the workspace to update

- displayName:

  New display name for the workspace

## Value

A data.table indicating the update status.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_updateWorkspace(workspace = "my_ws", displayName = "Renamed Workspace")
} # }
```
