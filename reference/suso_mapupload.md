# Upload map to server

Allows the user to upload a zip file of background maps and boundary
files

## Usage

``` r
suso_mapupload(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  path_to_zip = NULL
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

- path_to_zip:

  either path to zip file or directory of files which will automatically
  be zipped as required

## Value

Returns a data.table, with information about the uploaded maps

## Details

Resources for upload must meet the requirements specified under:
<https://docs.mysurvey.solutions/headquarters/mapsmanage/map-formats/>,
Attention: this uses the GraphQL API, not the REST API.

## Examples

``` r
if (FALSE) { # \dontrun{
# either upload the content of a folder
suso_mapupload(workspace = "myworkspace",
              path_to_zip = "./mapfiles/")

# or a zip file with the files included
suso_mapupload(workspace = "myworkspace",
              path_to_zip = "../mapfiles/maps.zip")
} # }



```
