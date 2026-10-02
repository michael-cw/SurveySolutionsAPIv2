# Assignment Classes & Methods

Assignments class extends the data.table class to include relevant
methods

## Usage

``` r
assignmentClass(x, ...)
```

## Arguments

- x:

  list returned by api call

- ...:

  additional attributes to be added to the assignmentClass

## Value

assignmentClass object

## Details

The assignmentClass is a data.table extended with additional attributes
and methods, depending on the api endpoint. The assignmentClass is used
as input for the `getinfo` function.

## Examples

``` r
ass_list <- list(Assignments = data.frame(Id = 1, ResponsibleName = "interviewer1"))
ac <- assignmentClass(ass_list)
is.assignmentClass(ac)
#> [1] TRUE
```
