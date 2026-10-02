# Get statistics for interview

Fetch statistics for a specific interview, vectorized over interview id
(int_id)

## Usage

``` r
suso_get_stats_interview(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = ""
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

- intID:

  a single or multiple *InterviewId*.

## Value

A data.table containing statistics for the requested interview(s).

## Examples

``` r
if (FALSE) { # \dontrun{
suso_get_stats_interview(
          workspace = "myworkspace",
          intID = "dee7705f-d611-4b12-9b97-2b8e5b80c4ea"
          )

} # }
```
