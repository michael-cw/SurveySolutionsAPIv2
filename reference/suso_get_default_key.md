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
if (FALSE) { # \dontrun{
suso_get_default_key("susoServer")
} # }
```
