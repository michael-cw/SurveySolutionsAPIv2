# Export Classes & Methods

Export class extends the data.table class to include relevant methods

## Usage

``` r
exportClass(x, varLabels, ..., type = "main")
```

## Arguments

- x:

  list returned by api call

- varLabels:

  data.table of variable labels as returned by
  `suso_getQuestDetails(operation.type = "structure")`

- ...:

  additional attributes to be added to the ExportClass

- type:

  one of main or para, if main returns exportClass object for the main
  data, if para, returns an exportClass object for the paradata.

## Value

An object of class exportClass (inheriting from data.table)

## Examples

``` r
dt <- data.table::data.table(q1 = 1:5)
vlabs <- data.table::data.table(VariableName = "q1", QuestionText = "Question 1")
ec <- exportClass(dt, varLabels = vlabs)
is.exportClass(ec)
#> [1] TRUE
```
