# Delete Map from Server

Allows the user to delete maps stored on the server.

## Usage

``` r
suso_deletemap(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  fileName = NULL
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

  server workspace, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- fileName:

  the name of the map file on the server

## Value

A data.table containing the deleted map details (file name, shape type,
and import timestamp).

## Examples

``` r
if (FALSE) { # \dontrun{
suso_deletemap(
  workspace = "myworkspace",
  fileName = "Lat9264Lon625_ALL.tif"
)
} # }
```
