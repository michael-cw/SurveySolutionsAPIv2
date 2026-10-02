# Function to check if an object is of class exportClass

Function to check if an object is of class exportClass

## Usage

``` r
is.exportClass(x)
```

## Arguments

- x:

  object to be checked

## Value

TRUE if object is of class exportClass

## Examples

``` r
dt <- data.table::data.table(q1 = 1:5)
vlabs <- data.table::data.table(VariableName = "q1", QuestionText = "Question 1")
ec <- exportClass(dt, varLabels = vlabs)
is.exportClass(ec)
#> [1] TRUE
is.exportClass(dt)
#> [1] TRUE
```
