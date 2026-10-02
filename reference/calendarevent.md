# Create, update or delete a calendar event

Create, update or delete a calendar event for one or several assignments
or interviews.

## Usage

``` r
suso_createCALEV(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = NULL,
  AssId = NULL,
  comment = NULL,
  startDate = NULL,
  startTime = NULL,
  startTZ = "UTC"
)

suso_updateCALEV(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  publicKey = NULL,
  comment = NULL,
  startDate = NULL,
  startTime = NULL,
  startTZ = "UTC"
)

suso_delCALEV(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  publicKey = NULL
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

  server workspace, if nothing provided, defaults to primary

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored

- intID:

  UUID vector of interview id(s)

- AssId:

  numeric vector of assignment id(s)

- comment:

  a comment string

- startDate:

  new start date, format must be: `2024-01-16`

- startTime:

  new start date, format must be: `01:41:14`

- startTZ:

  time zone of the tablet device, use
  [`OlsonNames`](https://rdrr.io/r/base/timezones.html)

- publicKey:

  UUID vector of calender event id(s)

## Value

a data.table with the created event(s).

## Details

This function creates a calendar event either for one or several
assignments or one or several interviews. Either one of `AssID` or
`intID` must not be NULL. If `length(AssID)` or `length(AssID)` is
greater 1, then `startDate`, `startTime` and `startTZ` must either be
each of length 1 (same event for all) or of the same length, allowing
for multiple events with different times.

## Functions

- `suso_createCALEV()`: add a calendar event

- `suso_updateCALEV()`: update a calendar event

- `suso_delCALEV()`: delete a calendar event

## Examples

``` r
if (FALSE) { # suso_PwCheck() == 200
# add single calendar event to assignment
calEvass<-suso_createCALEV(AssId = 268,
                           startDate = "2024-01-17",
                           startTime = "10:40:00")

# update single event
calEvup<-suso_updateCALEV(publicKey = calEvass$publicKey[1],
                         startDate = "2024-01-18",
                        startTime = "10:40:00")

# delete single event
calEvDel<-suso_delCALEV(publicKey = calEvup$publicKey[1])


# add calendar event to multiple assignments
calEvass<-suso_createCALEV(AssId = 55:60,
                           startDate = "2024-01-18",
                           startTime = "11:40:00")
# delete multiple calendar events
calEvDel<-suso_delCALEV(publicKey = calEvass$publicKey)

}
```
