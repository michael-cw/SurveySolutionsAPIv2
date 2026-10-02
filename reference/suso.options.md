# Configuration options used for the SurveySolutionsAPIv2 package

Below are the options and environment variables, that are used by the
SurveySolutionsAPIv2 package.

## Value

No return value, called for documentation on package configuration
options.

## Available options

Bellow is a list of options, with their default values.

- suso.url.http if TRUE allows for non SSL connections, which is
  generally not recommended for publicly facing set-ups, however may be
  required for testing purposes.

- suso.maxpar.req specifies the maximum number of parallel requests,
  default is 100.

- suso.maxpar.con specifies the maximum number of parallel connections,
  and must always be equal or greater than suso.maxpar.req, default is
  100.

- suso.para.break specifies the maximum response time to be considered
  as a break in seconds, default 120.

- suso.para.tz specifies the local timezone for the processing of time
  values, default is
  [`Sys.timezone()`](https://rdrr.io/r/base/timezones.html).

- suso.para.maxcore specifies the number of cores used for parallel
  processing, default is `data.table::getDTthreads()-2`.

- suso.para.plan specifies plane used for parallel processing, default
  is `multisession`. For details please see
  `future::`[`plan`](https://future.futureverse.org/reference/plan.html)

- suso.useshiny should R shiny elements be used if running in shiny app,
  default is TRUE. Currently implemented for:

  - [`suso_PwCheck`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_PwCheck.md),
    providing feedback for credentials check, the
    suso.pwcheck.message_succ and suso.pwcheck.message_fail can be
    modified.

  - [`suso_export`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export.md),
    providing different progress bars for interactive (cli) use and in
    shiny app use
    (`shiny::`[`withProgress`](https://rdrr.io/pkg/shiny/man/withProgress.html),
    to also customize the progress bar message, i.e. in a different
    language, the suso.progressbar.message can be modified.

  - TBD

## Examples

``` r
# Inspect the current maximum parallel requests option
getOption("suso.maxpar.req", default = 100)
#> [1] 100

# Inspect the timezone option
getOption("suso.para.tz", default = Sys.timezone())
#> [1] "UTC"
```
