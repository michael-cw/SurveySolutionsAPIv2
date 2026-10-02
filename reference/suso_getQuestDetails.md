# Survey Solutions API call for questionnaire

`suso_getQuestDetails` implements all Questionnaire related API
commands. It allows for different operation types, see details bellow
for further clarification.

## Usage

``` r
suso_getQuestDetails(
  server = suso_get_api_key("susoServer"),
  apiUser = suso_get_api_key("susoUser"),
  apiPass = suso_get_api_key("susoPass"),
  workspace = suso_get_api_key("workspace"),
  token = NULL,
  questID = NULL,
  version = NULL,
  operation.type = c("list", "statuses", "structure", "interviews"),
  include_raw = FALSE,
  AssId = NULL,
  InterviewKey = NULL,
  errorsCount = NULL,
  errosCountFilter = c("lower", "higher", "equal"),
  interviewMode = c("CAPI", "CAWI"),
  notAnsweredCount = NULL,
  notAnsweredCountFilter = c("lower", "higher", "equal"),
  QuestionnaireVariable = NULL,
  ResponsibleName = NULL,
  responsibleRole = c("INTERVIEWER", "SUPERVISOR"),
  workStatus = c("All", "SupervisorAssigned", "InterviewerAssigned",
    "RejectedBySupervisor", "Completed", "ApprovedBySupervisor",
    "RejectedByHeadquarters", "ApprovedByHeadquarters"),
  supervisorName = NULL
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

  If Survey Solutions server token is provided *usr* and *pass* will be
  ignored

- questID:

  *QuestionnaireId* for which details should be exported

- version:

  questionnaire version

- operation.type:

  if *list* is specified a list of all questionnaires on the server. If
  *statuses* a vector of all questionnaire statuses. If *structure* is
  specified, it returns a list containing all questions, rosters etc. of
  the specific questionnaire, as well as all validations. If
  *interviews* is specified, all interviews for a specific
  questionnaire. See details bellow.

- include_raw:

  logical; if `TRUE`, retains the raw JSON list column (`..JSON`) in the
  question table when `operation.type = "structure"`. Default is `FALSE`
  for clean, flat data tables.

- AssId:

  Assignment ID (only required if operations.type is*interviews*)

- InterviewKey:

  Interview key (only required if operations.type is*interviews*)

- errorsCount:

  desired number of errors (only required if operations.type
  is*interviews*)

- errosCountFilter:

  relational type for error counts, either smaller equal, equal or
  greater equal than the number specified in `errorsCount`, if not
  supplied defaults to lower equal than *interviews*) (only required if
  operations.type is*interviews*)

- interviewMode:

  Interview mode (CAWI or CAPI) (only required if operations.type
  is*interviews*)

- notAnsweredCount:

  number of unanswered questions (only required if operations.type
  is*interviews*)

- notAnsweredCountFilter:

  relational type for unanswered question counts, either smaller equal,
  equal or greater equal than the number specified in
  `notAnsweredCount`, if not supplied defaults to lower equal than
  *interviews*) (only required if operations.type is*interviews*)

- QuestionnaireVariable:

  the variable for the questionnaire (only required if operations.type
  is*interviews*)

- ResponsibleName:

  Name of the person responsible (only required if operations.type
  is*interviews*)

- responsibleRole:

  Role of the person responsible (only required if operations.type
  is*interviews*)

- workStatus:

  of the interview (only required if operations.type is*interviews*)

- supervisorName:

  Name of the supervisor of the responsible user (only required if
  operations.type is*interviews*)

## Value

Depending on `operation.type`:

- list:

  A data.table listing all questionnaires on the server.

- statuses:

  A character vector of questionnaire statuses.

- structure:

  A list with four data.tables: `q` (questions/rosters metadata), `val`
  (validations), `v` (alias for `val`), and `answers` (categorical
  answer options and codes).

- interviews:

  A data.table listing interviews for the specified questionnaire.

## Details

If list is selected, then list of questionnaires is returned.

If statuses is selected, a list of all available questionnaire statuses
is returned (deprecated).

In case structure is chosen the return value is a list with four
data.table elements:

- List element *q* contains all questions, rosters etc. with full
  metadata.

- List element *val* contains all validations.

- List element *v* is an alias for *val* for backward compatibility.

- List element *answers* contains categorical answer options, codes, and
  linked questions.

In this way it is straightforward to use the return value for
questionnaire manuals and the likes.

In case interviews is selected, a list of all interviews for the
specific questionnaire is returned.

## Examples

``` r
if (FALSE) { # \dontrun{
# List all questionnaires on the server
q_list <- suso_getQuestDetails(operation.type = "list")

# Get questionnaire structure (questions, validations, answers)
q_struct <- suso_getQuestDetails(
  questID = q_list$QuestionnaireId[1],
  version = q_list$Version[1],
  operation.type = "structure"
)
} # }
```
