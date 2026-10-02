# Survey Solutions API call for questionnaires with statistics

Retrieves the list of questionnaires that have statistics data on the
server.

## Usage

``` r
suso_getStatsQuestionnaires(
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

  server workspace, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

## Value

A data.table listing questionnaires with statistics.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getStatsQuestionnaires()
} # }
```
