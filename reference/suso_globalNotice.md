# Survey Solutions API call for Headquarters Global Notice settings

Allows getting, setting, and removing the global notice displayed in the
Survey Solutions Headquarters application.

## Usage

``` r
suso_globalNotice(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  action = c("get", "set", "delete"),
  message = NULL
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

- action:

  Action to perform: `"get"` to retrieve the notice, `"set"` to update
  the notice, or `"delete"` to remove the notice

- message:

  Character string containing the notice message. Required when
  `action = "set"`.

## Value

When `action = "get"`, returns a character string with the current
notice (or NULL if no notice is set). When `action = "set"` or
`"delete"`, returns `TRUE` invisibly on success.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get current global notice
suso_globalNotice(action = "get")

# Set a new global notice
suso_globalNotice(action = "set",
                  message = "Maintenance tonight at 22:00 UTC.")

# Delete the global notice
suso_globalNotice(action = "delete")
} # }
```
