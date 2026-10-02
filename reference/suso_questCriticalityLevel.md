# Survey Solutions API call for questionnaire criticality level setting

Gets or sets the criticality level setting for a specific questionnaire.

## Usage

``` r
suso_questCriticalityLevel(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL,
  level = NULL
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

  Questionnaire version (numeric)

- level:

  Criticality level to set: `"Unknown"`, `"Ignore"`, `"Warn"`, or
  `"Block"`. If `NULL` (default), gets the current criticality level
  setting.

## Value

When `level = NULL`, returns the current criticality level setting. When
`level` is provided, returns `TRUE` invisibly upon successful update.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get current criticality level
suso_questCriticalityLevel(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1
)
# Set criticality level to Warn
suso_questCriticalityLevel(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1,
  level = "Warn"
)
} # }
```
