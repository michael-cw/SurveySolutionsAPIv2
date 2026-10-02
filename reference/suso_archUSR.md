# Survey Solutions API call (un-) archive user

(Un-)Archive user

## Usage

``` r
suso_archUSR(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  user_id = NULL,
  archive = F,
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

- archive:

  if TRUE user will be archived or statys archived, if FALSE user will
  be unarchived or stays unarchived

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace, if no workspace is provided defaults to primary workspace.

- token:

  If Survey Solutions server token is provided *usr* and *pass* will be
  ignored

## Value

A data.table containing the user ID, archive timestamp, and archive
status.

## Examples

``` r
if (FALSE) { # \dontrun{
# you can archive a user by archive=T
suso_archUSR(
          workspace = "myworkspace",
          user_id = "xxxx-xxxx-xxxx-xxx",
          archive = TRUE
          )
# and unarchive a user by archive=F
suso_archUSR(
          workspace = "myworkspace",
          user_id = "xxxx-xxxx-xxxx-xxx",
          archive = FALSE
          )
} # }
```
