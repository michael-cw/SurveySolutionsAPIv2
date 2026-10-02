# S3 method to create a summary table of numeric variables for an exportClass object

This function generates a summary table of numeric variables in an
exportClass object.

## Usage

``` r
summaryTable(x, ...)

# S3 method for class 'exportClass'
summaryTable(x, ..., includeFactors = FALSE, useDT = TRUE, DTstyle = TRUE)

# S3 method for class 'paradata'
summaryTable(x, ..., useDT = TRUE, DTstyle = TRUE)
```

## Arguments

- x:

  exportClass object.

- ...:

  further arguments.

- includeFactors:

  if `TRUE`, factor variables will be converted to numeric and included
  in the table.

- useDT:

  Logical, if TRUE (default) the function returns a DataTable (DT)
  object (HTML table), otherwise a data.table object is returned.

- DTstyle:

  if `TRUE` and `useDT = TRUE`, then a custom style will be applied,
  otherwise a plain DT table will be returned.

## Value

A DataTable (DT) object (HTML table) displaying the summary statistics,
if `useDT = TRUE`, and a plain data.table otherwise.

## Details

- For the main data: The table includes statistics such as mean,
  standard deviation, maximum, minimum, and total count as well as count
  of NA values.

&nbsp;

- For paradata: Different summary tables for response times, duration
  times etc. see examples.

## Examples

``` r
if (FALSE) { # \dontrun{
questlist<-suso_getQuestDetails()

### MAIN DATA
export <- suso_export(questID = questlist$QuestionnaireId[7],
                      version = questlist$Version[7],
                      combineFiles = T,
                      reloadTimeDiff = 20)

# Create a summary table
summary_data_table <- summaryTable(export)

# Display the summary table
summary_data_table



} # }

if (FALSE) { # \dontrun{
questlist<-suso_getQuestDetails()

### PARADATA
# 1. Pre-Processed tables created during export
para<-suso_export_paradata(questID = questlist$QuestionnaireId[1],
                          version = questlist$Version[1], reloadTimeDiff = 24,
                          workStatus = "All", asList = F, onlyActiveEvents = T)

# Create a summary table of all event counts by action (includes always passive and active one)
actions <- summaryTable(para, "action")

# Create a summary table of all event counts by user
users <- summaryTable(para, "user")

# 2. Tables created on request for response times
# grouped by variables, i.e. type, VariableName, responsible etc.

# Create a summary table of the average response time by variable
resptime_var <- summaryTable(para, "VariableName")

# Create a summary table of the average response time by question type
resptime_type <- summaryTable(para, "type")

# Create a summary table of the average response time by user
resptime_user <- summaryTable(para, "responsible")


} # }
```
