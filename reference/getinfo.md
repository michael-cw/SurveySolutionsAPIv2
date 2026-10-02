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
if (FALSE) { # \dontrun{

# retrieve the uid of the person responsible after retrieving details for specific assignment
getinfo(asslist, "responsibleid")

# see all available attribute names
getinfo(asslist, "arglist")

} # }
```
