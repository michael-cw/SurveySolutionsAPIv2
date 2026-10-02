# Survey Solutions API call for Summary Tables

Returns summary tables for individual questions from Survey Solutions
statistics. If no responses have been provided, an empty table will be
returned.

## Usage

``` r
suso_get_stats(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL,
  qQuest = "",
  byTeam = TRUE,
  exportType = c("Csv", "Json")
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

- questID:

  Questionnaire ID (GUID)

- version:

  Version of the questionnaire (numeric)

- qQuest:

  Question variable name or UUID

- byTeam:

  Logical, whether the table should contain reports by team (default:
  `TRUE`)

- exportType:

  Report format: `"Csv"` (default) or `"Json"`

## Value

A data.table containing the summary statistics for the question.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_get_stats(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1,
  qQuest = "age"
)
} # }
```
