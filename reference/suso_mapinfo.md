# Receive maps currently uploaded to the server

Allows the user to retrieve filtered or unfiltered map data inlcuding
map details, like size, assigned users etc..

## Usage

``` r
suso_mapinfo(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  fileName = NULL,
  importDateUtc = NULL,
  size = NULL,
  users = NULL,
  sortby_filename = NULL,
  sortby_importeddateutc = NULL,
  sortby_size = NULL,
  take = NULL,
  skip = NULL
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

  name of the map on the server

- importDateUtc:

  Import date

- size:

  Size of the map

- users:

  Users to whom the maps are assigned

- sortby_filename:

  sort maps by file name, either ASC for ascending or DESC for
  descending

- sortby_importeddateutc:

  sort maps by import date in utc, either ASC for ascending or DESC for
  descending

- sortby_size:

  sort by map size, either ASC for ascending or DESC for descending

- take:

  take the specified integer numeber of maps

- skip:

  skip the first integer number of maps

## Value

Returns a data.table, with all the maps and additonal information. If
multiple users are assigned to a map, the table is expanded, such that
there is one user per map.

## Details

Attention: this uses the GraphQL API, not the REST API.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_mapinfo(workspace = "myworkspace")
} # }
```
