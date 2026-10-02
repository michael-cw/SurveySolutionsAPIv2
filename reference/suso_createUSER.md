# Survey Solutions API call for User Creation

Creates Survey Solutions users (observers, interviewers or supervisors).

## Usage

``` r
suso_createUSER(
  userlist = NULL,
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  showUser = FALSE
)
```

## Arguments

- userlist:

  dataframe with upload data

- server:

  Survey Solutions server address

- apiUser:

  Survey Solutions API user

- apiPass:

  Survey Solutions API password

- workspace:

  server workspace, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- showUser:

  userName in console

## Value

A data.table containing the user information and HTTP response status
code for each created user.

## Details

Dataframe needs to be provided with the mandatory columns for user
creation which are: Role, UserName, Password and Supervisor (in case of
interviewer), optional you can also provide FullName, PhoneNumber and
Email. Return value is a data.table, which includes the user information
as well as the response's status code. Important is also that the
UserName and Password are provided in the required format.

## Examples

``` r
if (FALSE) { # \dontrun{
new_users <- data.frame(
  Role = "Interviewer",
  UserName = "interviewer01",
  Password = "Password123!",
  Supervisor = "supervisor01"
)
suso_createUSER(userlist = new_users)
} # }
```
