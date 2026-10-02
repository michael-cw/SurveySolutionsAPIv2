# Survey Solutions API call for list of interviewers

Get list of all interviewers by supervisor id, or a list of all
interviewers in the workspace.

## Usage

``` r
suso_getINT(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  sv_id = NULL,
  bigTeam = FALSE
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace, if no workspace is provided defaults to primary workspace.

- token:

  If Survey Solutions server token is provided *usr* and *pass* will be
  ignored

- sv_id:

  supervisor id, if NULL all interviewers in the workspace are returned,
  and a column with sv_id is added

- bigTeam:

  (only if sv_id=NULL) if TRUE, requests will be performed sequential,
  and individual teams can be bigger than 100 if FALSE requests will be
  performed in parallel, but do not allow for teams larger 100
  interviewers.

## Value

An object of class UserClass (inheriting from data.table) containing the
interviewers.

## Examples

``` r
if (FALSE) { # \dontrun{

# Get all members for a single supervisor
suso_getINT(
          sv_id = "xxxx-xxxx-xxxx-xxx"
          )

# Get all members in the workspace
suso_getINT()

} # }
```
