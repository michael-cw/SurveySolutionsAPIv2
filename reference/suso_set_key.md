# Set all credentials at once

Sets API credentials so it's available for all API calls. See details

## Usage

``` r
suso_set_key(
  suso_server = "",
  suso_user = "",
  suso_password = "",
  workspace = NULL,
  suso_token = ""
)
```

## Arguments

- suso_server:

  Survey Solutions server address

- suso_user:

  Survey Solutions API user

- suso_password:

  Survey Solutions API password

- workspace:

  server workspace Name, if nothing provided, defaults to primary

- suso_token:

  If Survey Solutions server token is provided *suso_user* and
  *suso_password* will be ignored

## Value

Invisible NULL.

## Details

Use `suso_set_key` to make API keys available for all the `suso_`
functions, so you don't need to specify the credentials parameter within
those functions. The server address can be provided with or without
https:\\ suffix, nevertheless if it is missing, then the suffix will be
added. For testing purposes it also allows for http connections, however
for publicly accessible servers we do not recommend unencrypted
connections.

In case *suso_token* is provided, only token authentication will be
attempted. For details on token authentication in Survey Solutions
please see
<https://docs.mysurvey.solutions/headquarters/accounts/token-based-authentication/>.

## Examples

``` r
if (FALSE) { # \dontrun{
suso_set_key(
  suso_server = "https://demo.mysurvey.solutions",
  suso_user = "api_user",
  suso_password = "password123",
  workspace = "primary"
)
} # }
```
