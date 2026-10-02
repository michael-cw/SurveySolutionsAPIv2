# Enable or disable a workspace

Enables or disables access to a specified workspace. Accessible only to
administrator.

## Usage

``` r
suso_enableWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = NULL,
  enable = TRUE
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

  Name of the workspace

- enable:

  Logical, if TRUE enables the workspace, if FALSE disables it. Default
  is TRUE.

## Value

A data.table indicating the enable/disable status.

## Examples

``` r
if (FALSE) { # \dontrun{
# Enable workspace
suso_enableWorkspace(workspace = "my_ws", enable = TRUE)
# Disable workspace
suso_enableWorkspace(workspace = "my_ws", enable = FALSE)
} # }
```
