# Survey Solutions API call to list export processes

Retrieves a list of export processes matching specified filters.

## Usage

``` r
suso_getExportList(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  exportType = NULL,
  interviewStatus = NULL,
  questID = NULL,
  version = NULL,
  exportStatus = NULL,
  hasFile = NULL,
  limit = NULL,
  offset = NULL
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

  server workspace, if nothing provided, defaults to primary

- exportType:

  Format of export data: `"Tabular"`, `"STATA"`, `"SPSS"`, `"Binary"`,
  `"DDI"`, `"Parquet"`

- interviewStatus:

  Status of exported interviews: `"All"`, `"SupervisorAssigned"`,
  `"InterviewerAssigned"`, `"RejectedBySupervisor"`, `"Completed"`,
  `"ApprovedBySupervisor"`, `"RejectedByHeadquarters"`,
  `"ApprovedByHeadquarters"`

- questID:

  Questionnaire ID (GUID)

- version:

  Questionnaire version

- exportStatus:

  Status of export process: `"Created"`, `"Running"`, `"Completed"`,
  `"Fail"`, `"Canceled"`

- hasFile:

  Logical, whether the export process has a file ready to download

- limit:

  Maximum number of records to return

- offset:

  Number of records to skip

## Value

A data.table containing the list of export processes.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all export processes in workspace
exp_list <- suso_getExportList()
} # }
```
