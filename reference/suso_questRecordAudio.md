# Survey Solutions API call for questionnaire audio recording setting

Gets or sets the audio recording setting for a specific questionnaire.

## Usage

``` r
suso_questRecordAudio(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL,
  enabled = NULL
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

- enabled:

  Logical. If provided (`TRUE` or `FALSE`), updates the audio recording
  setting. If `NULL` (default), retrieves the current audio recording
  setting.

## Value

When `enabled = NULL`, returns a list with `Enabled` (logical) and
`AudioAuditScope` (character vector). When `enabled` is provided,
returns `TRUE` invisibly upon successful update.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get current audio recording setting
suso_questRecordAudio(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1
)
# Enable audio recording
suso_questRecordAudio(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1,
  enabled = TRUE
)
} # }
```
