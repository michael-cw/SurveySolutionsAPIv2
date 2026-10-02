# Function to check if an object is of class assignmentClass

Function to check if an object is of class assignmentClass

## Usage

``` r
is.assignmentClass(x)
```

## Arguments

- x:

  object to be checked

## Value

TRUE if object is of class assignmentClass

## Examples

``` r
ac <- assignmentClass(list(Assignments = data.frame(Id = 1)))
is.assignmentClass(ac)
#> [1] TRUE
is.assignmentClass(data.frame())
#> [1] FALSE
```
