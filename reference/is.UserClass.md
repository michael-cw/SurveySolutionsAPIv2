# Function to check if an object is of class UserClass

Function to check if an object is of class UserClass

## Usage

``` r
is.UserClass(x)
```

## Arguments

- x:

  object to be checked

## Value

TRUE if object is of class UserClass

## Examples

``` r
uc <- UserClass(list(Users = data.frame(UserName = "interviewer1")))
is.UserClass(uc)
#> [1] TRUE
is.UserClass(data.frame())
#> [1] FALSE
```
