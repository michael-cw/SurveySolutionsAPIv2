# Survey Solutions API call to assign workspace (!! WORKS ONLY WITH ADMIN CREDENTIALS)

`suso_assignWorkspace` Allows you to assign a workspace to a specific
user or a group of users. For more details please read
<https://docs.mysurvey.solutions/headquarters/accounts/workspaces/>. To
run this command you require admin credentials and not the regular API
user credentials.

## Usage

``` r
suso_assignWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  assign_workspace = NULL,
  keep_old_workspace = TRUE,
  uid = NULL,
  sv_id = NULL
)
```

## Arguments

- server:

  Survey Solutions server address.

- apiUser:

  Survey Solutions ADMIN user.

- apiPass:

  Survey Solutions ADMIN password.

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored.

- assign_workspace:

  The workspace which you want to assign to the new user.

- keep_old_workspace:

  if TRUE, exsting assigned workspaces will be kept, if FALSE only the
  new one will be assigned, see details.

- uid:

  Either a single User ID of the user to be assigned, or a vector.

- sv_id:

  The supervisor's ID to which the interviewer should be assigned to, if
  it is a supervisor who is assigned, just use the same as in *uid*.
  Must be the same length as `uid`

## Value

If successful, returns a data.table with the details as well as the
Status message `workspace list updated`.

A data.table containing the assignment update status.

## Details

When `keep_old_workspace=FALSE` the user will only be assigned to the
new workspace, otherwise the existing ones will be added, if the former
is the case, then you need to make sure, that all assignments,
interviews, team members etc. are cleared in the old workspace. Be
aware, that for using this call you require admin credentials, and not
the regular API user credentials.

## Examples

``` r
if (FALSE) { # \dontrun{
## Use Admin Credentials!

# Assign a new workspace to a single user, keep old one(s)
suso_assignWorkspace(
          assign_workspace = "myworkspace1",
          uid = "xxx-xxx-xxx-xxx-xxx",
          sv_id = "xxx-xxx-xxx-xxx-xxx",
          apiUser = "xxxxxx",
          apiPass = "xxxxxx",
          keep_old_workspace = TRUE
          )

# Assign a new workspace to a single user, drop old one(s)
suso_assignWorkspace(
          assign_workspace = "myworkspace1",
          uid = "xxx-xxx-xxx-xxx-xxx",
          sv_id = "xxx-xxx-xxx-xxx-xxx",
          apiUser = "xxxxxx",
          apiPass = "xxxxxx",
          keep_old_workspace = TRUE
          )

# Assign all supervisors from on workspace to a new one, keep old one
allsv<-suso_getSV(workspace = "old")
suso_assignWorkspace(
          assign_workspace = "new",
          uid = allsv$UserId,
          sv_id = allsv$UserId,
          apiUser = "xxxxxx",
          apiPass = "xxxxxx",
          keep_old_workspace = TRUE
          )

# Assign all interviewers from one workspace to a new one, keep old one
allint<-suso_getINT(workspace = "old")
suso_assignWorkspace(
          assign_workspace = "new",
          uid = allint$UserId,
          sv_id = allint$sv_id,
          apiUser = "xxxxxx",
          apiPass = "xxxxxx",
          keep_old_workspace = TRUE
          )

} # }
```
