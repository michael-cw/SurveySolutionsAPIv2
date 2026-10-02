# Convenience Function to modify the maximum number of parallel requests option

This function allows to modify the maximum number of parallel requests
suso.maxpar.req in a single call. It also checks the maximum number of
parallel connections, and if lower than the number of requests `max_req`
then also sets the suso.maxpar.con option to `max_req`.

## Usage

``` r
suso_set_maxpar_req(max_req = 100)
```

## Arguments

- max_req:

  set the number of parallel requests for all functions which

## Value

Invisible NULL.

## Examples

``` r
# Set maximum parallel requests to 50
suso_set_maxpar_req(50)
# Reset back to default
suso_set_maxpar_req(100)
```
