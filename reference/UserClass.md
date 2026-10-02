# User Classes & Methods

Users class extends the data.table class to include relevant methods

## Usage

``` r
UserClass(x, ...)
```

## Arguments

- x:

  list returned by api call

- ...:

  additional attributes to be added to the assignmentClass

## Value

An object of class UserClass (inheriting from data.table)

## Examples

``` r
usr_list <- list(Users = data.frame(UserName = "interviewer1", Role = "Interviewer"))
uc <- UserClass(usr_list)
is.UserClass(uc)
#> [1] TRUE
```
