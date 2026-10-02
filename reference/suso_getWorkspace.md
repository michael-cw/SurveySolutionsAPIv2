# Survey Solutions API call for workspace information

`suso_getWorkspace` allows you to get the list of workspaces,
information about individual workspace names as well as workspace
statuses. Workspaces as well as Workspaces information can only be
accessed, if credentials are eligible. For more details please read
<https://docs.mysurvey.solutions/headquarters/accounts/workspaces/>

## Usage

``` r
suso_getWorkspace(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = NULL,
  status = FALSE
)
```

## Arguments

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- workspace:

  If workspace name is provide requests are made regarding this specific
  workspace

- status:

  if status is *TRUE* worskpace must be not NULL and status information
  about a specific workspace is requested

## Value

A data.table containing workspace information or status.

## Examples

``` r
if (FALSE) { # \dontrun{
# This assumes, that suso_PwCheck(workspace = "myworkspace") was
# sucessful

# shows all workspaces in the system AND the user has access to
suso_getWorkspace(
          status = F)

# shows details for specific workspace myworkspace
suso_getWorkspace(
          workspace = "myworkspace",
          status = T)
} # }
```
