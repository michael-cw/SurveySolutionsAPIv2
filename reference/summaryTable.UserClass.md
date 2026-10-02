# S3 method to create a summary table of users for UserClass object

This function generates a summary table of Users.

## Usage

``` r
# S3 method for class 'UserClass'
summaryTable(x, includeFactors = FALSE, useDT = TRUE, DTstyle = TRUE, ...)
```

## Arguments

- x:

  A UserClass object.

- includeFactors:

  if `TRUE`, factor variables will be converted to numeric and included
  in the table (only for exportClass).

- useDT:

  Logical, if TRUE (default) the function returns a DataTable (DT)
  object (HTML table), otherwise a data.table object is returned.

- DTstyle:

  if `TRUE` and `useDT = TRUE`, then a custom style will be applied,
  otherwise a plain DT table will be returned.

- ...:

  Additional arguments (not used).

## Value

A DataTable (DT) object (HTML table) if `useDT = TRUE`, and a plain
data.table otherwise. The table contains all users core data, plus
completed and assigned counts,

## Details

For very large tables you will get a warning when rendering in Rstudio,
however in a shiny app you have the option to use server side
processing: `DT::renderDataTable(..., server = TRUE)`. In cases where
`future` and `future.apply` is available on your system the additional
information will be retrieved in parallel (multisession), otherwise
sequential. For large data sets parallel processing is recommended.
Furthermore when processing in parallel, a progress bar for shiny
applications is included and active when running in a shiny application,
otherwise a cli progress bar will be displayed.

## Examples

``` r
if (FALSE) { # \dontrun{

allintprim<-suso_getINT(workspace = "primary")

# Create a summary table
summary_data_table <- summaryTable(allintprim)

# Display the summary table
summary_data_table
} # }
```
