# Checks if credentials are present

Helper function

## Usage

``` r
suso_get_default_key(
  api = c("susoServer", "susoUser", "susoPass", "workspace")
)
```

## Arguments

- api:

  one of susoServer, susoUser, susoPass, or workspace

## Value

Character string of the requested credential, or throws error if not
set.

## Examples

``` r
suso_set_key(
  suso_server = "https://demo.mysurvey.solutions",
  suso_user = "api_user",
  suso_password = "password123",
  workspace = "primary"
)
suso_get_default_key("susoServer")
#> [1] "https://demo.mysurvey.solutions/"
suso_clear_keys()
```
