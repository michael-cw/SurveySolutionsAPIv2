# Download interview PDF transcript

Downloads the PDF transcript of a completed interview.

## Usage

``` r
suso_getInterviewPDF(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  intID = "",
  path = NULL
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

  server workspace name

- token:

  API token

- intID:

  InterviewId (GUID)

- path:

  Destination file path for saving the PDF. If NULL, saves to tempdir.

## Value

The file path where the PDF was saved.

## Examples

``` r
if (FALSE) { # \dontrun{
pdf_path <- suso_getInterviewPDF(intID = "11111111-2222-3333-4444-555555555555")
} # }
```
