# Get credentials

Get API credentials

## Usage

``` r
suso_get_api_key(api = c("susoServer", "susoUser", "susoPass", "workspace"))
```

## Arguments

- api:

  one of susoServer, susoUser, susoPass, or workspace

## Value

Character string of the requested credential, or NA if not set.

## Details

Get credentials, used as input in API calls

## Examples

``` r
suso_get_api_key("susoServer")
#> [1] NA
suso_get_api_key("workspace")
#> [1] NA
```
