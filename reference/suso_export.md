# Survey Solutions API call to generate and download the data

Generates and downloads the data from your Survey Solutions server.

## Usage

``` r
suso_export(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  token = NULL,
  workspace = suso_get_api_key("workspace"),
  questID = NULL,
  version = NULL,
  from_date = NULL,
  from_time = "00:00:00",
  to_date = NULL,
  to_time = "23:59:59",
  workStatus = c("All", "SupervisorAssigned", "InterviewerAssigned",
    "RejectedBySupervisor", "Completed", "ApprovedBySupervisor",
    "RejectedByHeadquarters", "ApprovedByHeadquarters"),
  addTranslation = FALSE,
  translationLanguage = NULL,
  reloadTimeDiff = 1,
  inShinyApp = F,
  verbose = FALSE,
  weight_file = NULL,
  process_mapquestions = FALSE,
  combineFiles = TRUE,
  addsysfiles = FALSE
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

- questID:

  Questionnaire ID

- version:

  Questionnaire version

- from_date:

  if provided, only interviews started on this date or later will be
  included

- from_time:

  if provided, only interviews started at this time or later will be
  included

- to_date:

  if provided, only interviews started before or on this date will be
  included

- to_time:

  if provided, only interviews started before or at this time will be
  included

- workStatus:

  define which statuses the file should inlude (i.e.
  *Restored,Created,SupervisorAssigned,InterviewerAssigned,
  RejectedBySupervisor,ReadyForInterview,
  SentToCapi,Restarted,Completed,ApprovedBySupervisor,
  RejectedByHeadquarters,ApprovedByHeadquarters,Deleted*), if NULL all
  is exported

- addTranslation:

  if not NULL, the translation name as specified in the designer, which
  will then be applied to value and variable labels

- translationLanguage:

  if not NULL the desired translation to be applied, if NULL, the first
  one found will be applied, the same is true, if the provided
  translation language does not exist

- reloadTimeDiff:

  time difference in hours between last generated file and now (will be
  ignored when `from_date` and `to_date` is not `NULL`)

- inShinyApp:

  if True, file interacts with shiny progress bar. *DEPRECATED, not used
  any longer, only for compatability reasons with previous
  SurveySolutionsAPI R package.*

- verbose:

  if TRUE, prints out information about the progress

- weight_file:

  file path to file with survey weights. if provided, the weights will
  be added to the export

- process_mapquestions:

  (only when `combineFiles=FALSE`), should map questions be processed to
  spatial (sf) objects, if yes, gps and all types of mapquestions will
  be added to the list at their corresponding roster level, and with the
  prefix "sf\_" *(experimental!)*

- combineFiles:

  if TRUE, the export will be combined into single data.table, see
  details for the processing steps

- addsysfiles:

  if TRUE Survey Solutions system files, i.e.

  - assignment\_\_actions.tab

  - interview\_\_actions.tab

  - interview\_\_comments.tab

  - interview\_\_diagnostics.tab

  - interview\_\_errors.tab

  are also included. Ignored when `combineFiles=TRUE`.

## Value

a single exportClass data.table or a list of exportClass data.tables,
see details.

## Details

This API call uses the tab export format and uses information from the
included questionnaire document to assign value labels to any factor
variables. Currently this is done for single select and multiselect
questions. If you export the data with *combineFiles = FALSE* a list
will be returned with the following structure:

- it is returned as a LIST with up to 4 different lists. The list names
  are:

  - *main* Contains the top level data, and (if available interviewer
    comments)

  - *R1* All rosters in roster level 1

  - *R2* All rosters in roster level 2

  - *R3* All rosters in roster level 3

- Number of lists depends on the level of roster nesting

- If `process_mapquestions = TRUE` is provided, the different lists will
  also contain an sf object for each spatial variable found at the
  corresponding main/roster level (multipolygons, multipoints, points
  and lines), for details see also the
  [sf](https://r-spatial.github.io/sf/reference/sf.html) package.

- All variable names are transformed to lower case and categorical
  variables are consistently labeled

- List elements are returned as data.tables

- Allows for specification of reload time (i.e. generation of new
  download file)

- PRESERVES categorical labels *and* values.

If however, you export the data with *combineFiles = TRUE* a single
data.table containing all the data in wide format will be returned. This
is the result of the following processing steps:

- First all roster files are cast into wide format.

- Second the rosters are merged from bottom to top.

- Third the result of the previous step is merged with the main file

The resulting data.table contains value labels for factor variables. If
the file path to a weight file is provided, then these will be added
too, and is as such ready for analysis.

## Examples

``` r
if (FALSE) { # suso_PwCheck() == 200

questlist<-suso_getQuestDetails()

exp<-suso_export(questID = questlist$QuestionnaireId[1],
                 version = questlist$Version[1],
                 workStatus = "All", process_mapquestions = T,
                 combineFiles = T,
                 reloadTimeDiff = 0,
                 translationLanguage = "italian")
}
```
