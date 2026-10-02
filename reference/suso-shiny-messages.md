# Convenience functions to modify user notification text

These functions allow the user to customize certain notifications and
messages when used in shiny apps.

## Usage

``` r
suso_set_pwcheck_mess(mess_succ = NULL, mess_fail = NULL)

suso_set_prog_mess(mess = NULL)
```

## Arguments

- mess_succ:

  set the success message for
  [`suso_PwCheck`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_PwCheck.md)
  when used in shiny app.

- mess_fail:

  set the success message for
  [`suso_PwCheck`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_PwCheck.md)
  when used in shiny app.

- mess:

  set the message for the export progress bars when used in shiny app,
  used in
  [`suso_export`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export.md)
  and
  [`suso_export_paradata`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export_paradata.md)

## Value

always invisible `TRUE`.

## Examples

``` r
# Set custom notification messages for shiny app
suso_set_pwcheck_mess(mess_succ = "Connected successfully!", mess_fail = "Authentication failed!")
suso_set_prog_mess(mess = "Downloading data, please wait...")
```
