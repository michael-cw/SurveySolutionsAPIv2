# Survey Solutions API call for Assignment Creation

Creates assignment with ID data. Uses the httr2 package, and
specifically the
[`req_perform_parallel`](https://httr2.r-lib.org/reference/req_perform_parallel.html)
function. Compared to a sequential approach, this significantly and
safely decreases the overall processing time. Adjust relevant option
suso.maxpar.req for number of parallel processes to match the capacity
of your system (default is 100 parallel requests).

## Usage

``` r
suso_createASS(
  df = NULL,
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL
)
```

## Arguments

- df:

  dataframe with upload data for ID (identifying data) assignments, see
  details for structure.

- server:

  Survey Solutions server address.

- apiUser:

  Survey Solutions API user.

- apiPass:

  Survey Solutions API password.

- workspace:

  server workspace, if nothing provided, defaults to primary.

- token:

  If Survey Solutions server token is provided *apiUser* and *apiPass*
  will be ignored.

- questID:

  the questionnaire id.

- version:

  the questionnaire version.

## Value

Returns a data.table with a row for each assignment, containing
identifying data, responsible id etc.

## Details

Dataframe needs to be provided with columns for ID data, matching the
required type, as well as *Quantity* and *ResponsibleName*. Return value
is a data.table, with the ID data, if successful.

## Examples

``` r
if (FALSE) { # \dontrun{

# get the list of questionnaires in the workspace
questlist<-suso_getQuestDetails()


# Create the assignments with your upload data
asslist <- suso_createASS(df = IdentifyingData,
                          questID = questlist$QuestionnaireId[1],
                          version = questlist$Version[1])

} # }


```
