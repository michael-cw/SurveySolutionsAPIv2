# Survey Solutions API call for info on any user

Get any user's info, by either providing the user id, email, or the user
name

## Usage

``` r
suso_getUSR(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  user_id = NULL,
  user_name = NULL,
  user_email = NULL,
  workspace = suso_get_api_key("workspace"),
  token = NULL
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- user_id:

  user id

- user_name:

  user name

- user_email:

  user email

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace, if no workspace is provided defaults to primary workspace.

- token:

  If Survey Solutions server token is provided *usr* and *pass* will be
  ignored

## Value

A data.table containing user details.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_getUSR(
          workspace = "myworkspace",
          user_id = "xxxx-xxxx-xxxx-xxx"
          )
} # }
```
