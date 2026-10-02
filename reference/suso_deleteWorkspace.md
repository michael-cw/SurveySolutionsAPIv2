# Delete a workspace

Deletes a specified workspace. Accessible only to administrator.

## Usage

``` r
suso_deleteWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = NULL
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

  Name of the workspace to delete

## Value

A data.table indicating the deletion status.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_deleteWorkspace(workspace = "old_ws")
} # }
```
