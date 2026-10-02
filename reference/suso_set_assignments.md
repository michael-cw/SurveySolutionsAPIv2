# Survey Solutions API call for assignment manipulation

`suso_set_assignments` allows to (re-)assign, change limits or audio
recording settings, as well as archiving/unarchive, downsizing, changing
status/target area, and closing assignments.

## Usage

``` r
suso_set_assignments(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  AssId = NULL,
  payload = NULL,
  operations.type = c("recordAudio", "archive", "assign", "changeQuantity", "close",
    "unarchive", "downsize", "changeStatus", "changeTargetArea")
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

- AssId:

  the assignment id for which the change is required

- payload:

  requirements depend on the operations type. See details below.

- operations.type:

  specifies the desired operation, one of recordAudio, archive,
  unarchive, assign, changeQuantity, close, downsize, changeStatus,
  changeTargetArea.

## Value

Returns an S3 object of assignmentClass

## Details

If operations.type is *recordAudio*, `TRUE/FALSE` is required as
payload. If it is *archive*, *unarchive*, *close*, or *downsize*, no
payload is required. If it is *assign* the payload must be the uid of
the new responsible person. If it is *changeQuantity* the payload must
be the new integer number of assignments (-1 for unlimited). If it is
*changeStatus* the payload must be the new status string (e.g. "Closed",
"Deleted") or a named list with Status and optional Comment. If it is
*changeTargetArea* the payload must be the new target area string.

## Examples

``` r
if (FALSE) { # \dontrun{

# (re-)assign existing assignment
asslist<-suso_set_assignments(
                   workspace = "myworkspace",
                   AssId = 10,
                   payload = "43f3d2bd-7959-4706-97ae-2653b5685c9e",
                   operations.type = "assign"
                   )
# downsize assignment
asslist<-suso_set_assignments(
                   workspace = "myworkspace",
                   AssId = 10,
                   operations.type = "downsize"
                   )
} # }
```
