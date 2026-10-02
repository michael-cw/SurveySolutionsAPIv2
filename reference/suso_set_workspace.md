# Convenience function to switch workspace

Sets the workspace only, but leaves all other credentials the same.

## Usage

``` r
suso_set_workspace(workspace = NULL)
```

## Arguments

- workspace:

  server workspace Name (not the display name), if nothing provided,
  defaults to primary

## Value

invisibly TRUE if successful.

## Details

Use `suso_set_workspace` to make the desired workspace available for all
the `suso_` functions, so you don't need to specify the workspace
parameter within those functions. The function also checks if the
workspace name is correct, and the user with the current credentials is
authorized.If the workspace requires different credentials, then use
[`suso_set_key`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_key.md)
again.

## Examples

``` r
if (FALSE) { # \dontrun{

# switch to workspace "windows"
suso_set_workspace("windows")

# switch to primary (default) workspace
suso_set_workspace()

} # }
```
