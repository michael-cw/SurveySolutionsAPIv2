# S3 method to create a box plot of numeric variables for an exportClass object

This function generates a box plot for the numeric variables in a
exportClass object.

## Usage

``` r
boxplot_summary(x, useGGplot2 = FALSE, ...)

# S3 method for class 'exportClass'
boxplot_summary(x, useGGplot2 = FALSE, ...)
```

## Arguments

- x:

  A summaryTable object.

- useGGplot2:

  Logical, if TRUE (default) the function returns a ggplot2 object,
  otherwise a base R boxplot is returned.

- ...:

  Additional arguments (not used).

## Value

A box plot visualizing the numeric variables.

A ggplot2 plot object if useGGplot2 is TRUE, or a base R boxplot list
invisibly otherwise

## Examples

``` r
if (FALSE) { # \dontrun{
# Load your package
export <- suso_export(questID = questlist$QuestionnaireId[7],
                      version = questlist$Version[7],
                      combineFiles = T,
                      reloadTimeDiff = 20)

# Create a summary table
boxplot_summary <- boxplot(export)

# Display the summary table
boxplot_summary
} # }
```
