# Utility function to check if credentials are correct

This function returns a 200 status code if credentials are correct and a
400 code otherwise.

## Usage

``` r
suso_PwCheck(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL
)
```

## Arguments

- server:

  Survey Solutions Server

- apiUser:

  API user

- apiPass:

  API password

- workspace:

  server workspace Name, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

## Value

200 code if correct, 400 if incorrect.

## Details

If the app runs interactively, status is printed to the console, if it
runs in a shiny app, a status notification will be shown, if option
suso.useshiny is `TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_PwCheck(
  server = "https://demo.mysurvey.solutions",
  apiUser = "api_user",
  apiPass = "password123"
)
} # }
```
