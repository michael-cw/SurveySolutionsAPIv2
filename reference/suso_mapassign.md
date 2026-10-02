# Assigns/Unassign a map to a user

Allows the user to assign/unassign a map to an interviewer to be used in
CAPI data collection.

## Usage

``` r
suso_mapassign(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  fileName = NULL,
  userName = NULL,
  assignUser = TRUE
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

- userName:

  the name of the interviewer to whom the map will be assigned to

- assignUser:

  if TRUE user will be assigned to map, if FALSE user will be removed
  from map

## Value

A data.table containing the map assignment details (file name, user
name, shape type, and import timestamp).

## Examples

``` r
if (FALSE) { # \dontrun{
suso_mapassign(workspace = "myworkspace",
              fileName = "Lat9264Lon625_ALL.tif",
              userName = "INT0004")
} # }
```
