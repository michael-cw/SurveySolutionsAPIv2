# Survey Solutions API call for questions and responses from single questionnaire

Returns all questions for a single questionnaire (ONLY if they contain
responses). If you require all questions from any questionnaire on the
server, use `suso_getQuestDetails(..., operation.type = "structure")`.

## Usage

``` r
suso_getQuestionsQuestionnaire(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL
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

## Value

A data.table listing questions with responses for the questionnaire.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getQuestionsQuestionnaire(
  questID = "11111111-2222-3333-4444-555555555555",
  version = 1
)
} # }
```
