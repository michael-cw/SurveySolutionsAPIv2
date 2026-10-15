# assignmentClass methods

`getinfo` allows you to retrieve relevant additional information from
the `assignmentClass`, object depending on the api endpoint.

## Usage

``` r
getinfo(obj, arg)

# S3 method for class 'assignmentClass'
getinfo(obj, arg)

# S3 method for class 'exportClass'
getinfo(obj, arg)

# S3 method for class 'UserClass'
getinfo(obj, arg)
```

## Arguments

- obj:

  object of assignmentClass

- arg:

  name of attribute, if `arg="arglist"` then it returns all available
  arguments

## Value

the specific attribute

## Details

To retrieve all availalbe arguments use `arg="arglist"`

## Examples

``` r
ass_list <- list(
  Assignments = data.frame(Id = 1, ResponsibleName = "interviewer1"),
  ResponsibleId = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
)
asslist <- assignmentClass(ass_list)

# retrieve the uid of the person responsible
getinfo(asslist, "responsibleid")
#> [1] "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

# see all available attribute names
getinfo(asslist, "arglist")
#> [1] "responsibleid"
```
