# Survey Solutions API call to create workspace

`suso_createWorkspace` Allows you to create a workspace with a specific
system name and display name. For more details please read
<https://docs.mysurvey.solutions/headquarters/accounts/workspaces/>. To
run this command you require admin credentials.

## Usage

``` r
suso_createWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  new_workspace = NULL,
  displayName = NULL
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions ADMIN user

- apiPass:

  Survey Solutions ADMIN password

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- new_workspace:

  The name used by the system for this workspace. Make sure you follow
  the nameing rules outlined under
  <https://docs.mysurvey.solutions/headquarters/accounts/workspaces/>

- displayName:

  The name visible to the users

## Value

A data.table containing the created workspace information.

## Details

Be aware, that for using this call you require the ADMIN credentials,
and not the regular API user credentials.

## Examples

``` r
if (FALSE) { # \dontrun{
# Use Admin Credentials!
suso_createWorkspace(
          new_workspace = "myworkspace1",
          displayName = "SpecialWorkspace",
          apiUser = "xxxxxx",
          apiPass = "xxxxxx")
} # }

```
