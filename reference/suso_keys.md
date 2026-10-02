# Survey Solutions API credentials

(this function has been inspired by the googleway package
<https://github.com/SymbolixAU/googleway>, an excellent package to use
google geo-spatial API) Retrieves the list of Survey Solutions
credentials that have been set.

## Usage

``` r
suso_keys()
```

## Value

A list of class suso_api containing current Survey Solutions
credentials.

## Examples

``` r
suso_keys()
#> $suso
#> $suso$susoServer
#> [1] NA
#> 
#> $suso$susoUser
#> [1] NA
#> 
#> $suso$susoPass
#> [1] NA
#> 
#> $suso$workspace
#> [1] NA
#> 
#> 
#> attr(,"class")
#> [1] "suso_api"
```
