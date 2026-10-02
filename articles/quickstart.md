# Quickstart: Connecting and Exploring Your Server

## Introduction

**`SurveySolutionsAPIv2`** provides a complete R interface to the World
Bank’s [Survey Solutions](https://mysurvey.solutions) Computer-Assisted
Personal Interviewing (CAPI) and Computer-Assisted Web Interviewing
(CAWI) platform.

Powered by modern [`httr2`](https://httr2.r-lib.org/), it supports all
current Survey Solutions REST endpoints, GraphQL queries/mutations,
asynchronous batch exports, paradata processing, and questionnaire
parsing.

In this quickstart guide, you will learn how to: 1. Configure
credentials securely. 2. Verify server connectivity. 3. Manage and
switch workspaces. 4. Discover questionnaires deployed on your server.

------------------------------------------------------------------------

## 1. Setting Up Credentials

Survey Solutions servers support two authentication mechanisms: - **API
User and Password** (Basic Authentication) - **API Token** (Token-based
Authentication)

### Best Practice: Environment Variables

For security and reproducibility, avoid writing credentials directly
into scripts. Store them in your `.Renviron` file:

``` sh
# In ~/.Renviron
SUSO_SERVER="https://your-server.mysurvey.solutions"
SUSO_USER="your_api_user"
SUSO_PASSWORD="your_secure_password"
SUSO_WORKSPACE="primary"
```

### Initializing Credentials in R

Use
[`suso_set_key()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_key.md)
to configure the credentials in your active R session. Once configured,
all other functions automatically reuse these settings:

``` r

library(SurveySolutionsAPIv2)

# Set credentials using environment variables
suso_set_key(
  suso_server   = Sys.getenv("SUSO_SERVER", "https://your-server.mysurvey.solutions"),
  suso_user     = Sys.getenv("SUSO_USER", "api_user"),
  suso_password = Sys.getenv("SUSO_PASSWORD", "secret_pass"),
  workspace     = Sys.getenv("SUSO_WORKSPACE", "primary")
)
```

If using an API token:

``` r

suso_set_key(
  suso_server = "https://your-server.mysurvey.solutions",
  suso_token  = "your_api_token_here",
  workspace   = "primary"
)
```

### Checking and Clearing Stored Credentials

You can inspect the active configuration or retrieve individual
credentials:

``` r

# Inspect stored credentials (masked in output)
suso_keys()
#> $suso
#> $suso$susoServer
#> [1] NA
#> 
#> $suso$susoUser
#> [1] NA
#> 
#> $suso$susoPass
#> [1] NA
#> 
#> $suso$workspace
#> [1] NA
#> 
#> 
#> attr(,"class")
#> [1] "suso_api"

# Retrieve a specific active setting
suso_get_api_key("workspace")
#> [1] NA
```

To clear credentials from the session at any time:

``` r

suso_clear_keys()
```

------------------------------------------------------------------------

## 2. Testing Server Connectivity

Before launching survey operations, test connectivity and credentials
using
[`suso_PwCheck()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_PwCheck.md).
This function returns HTTP status code `200` on success, or `400` /
error if credentials or connectivity fail:

``` r

# Test connection to the default workspace
status <- suso_PwCheck()
if (status == 200) {
  message("Connected successfully to Survey Solutions!")
}
```

    #> Connected successfully to Survey Solutions!

------------------------------------------------------------------------

## 3. Discovering and Switching Workspaces

Survey Solutions allows segmenting operations across independent
workspaces.

### Listing All Workspaces

[`suso_getWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getWorkspace.md)
lists all workspaces available to the authenticated user:

``` r

workspaces <- suso_getWorkspace()
print(workspaces)
```

    #>       Name       DisplayName DisabledAtUtc CreatedAtUtc
    #>     <char>            <char>        <lgcl>       <lgcl>
    #> 1: primary Default Workspace            NA           NA

### Switching Workspaces

To switch the active workspace without re-entering server credentials,
use
[`suso_set_workspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_workspace.md):

``` r

# Switch to another workspace
suso_set_workspace("pilot_study")

# Switch back to the primary workspace
suso_set_workspace("primary")
```

------------------------------------------------------------------------

## 4. Discovering Deployed Questionnaires

To see all questionnaires published in the current workspace, call
[`suso_getQuestDetails()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getQuestDetails.md)
with `operation.type = "list"`:

``` r

quest_list <- suso_getQuestDetails(operation.type = "list")
print(quest_list[, .(Title, Variable, Version, QuestionnaireId)])
```

    #> Key: <Variable, QuestionnaireId, Version>
    #>                      Title       Variable Version
    #>                     <char>         <char>   <int>
    #> 1:    Yemen HBS 2025-Pilot hbs_yemen_2025       1
    #> 2: SuSo_Dashboard_Incoming     susodashin       1
    #>                         QuestionnaireId
    #>                                  <char>
    #> 1: 17a9fa22-1ef6-46d2-8c30-426aa876f273
    #> 2: a383ce13-1c14-4171-a3ca-7ffce2ae388a

The returned `QuestionnaireId` (GUID) and `Version` are the primary
identifiers needed for questionnaire structure extraction, assignment
creation, and data export.

------------------------------------------------------------------------

## 5. Global Package Options

`SurveySolutionsAPIv2` provides several options to control execution
behavior, concurrency, and Shiny integration:

``` r

# Default maximum parallel requests
getOption("suso.maxpar.req", default = 100)
#> [1] 100

# Modify parallel request ceiling
suso_set_maxpar_req(50)

# Reset to standard
suso_set_maxpar_req(100)
```

When integrating with Shiny apps, progress messages and credential
validation toasts can be customized using
[`suso_set_pwcheck_mess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso-shiny-messages.md)
and
[`suso_set_prog_mess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso-shiny-messages.md).

------------------------------------------------------------------------

## Next Steps

Now that you are connected, proceed to: - **[Questionnaires, Structure,
and
Codebooks](https://michael-cw.github.io/SurveySolutionsAPIv2/articles/questionnaires.md)**:
Learn how to parse questionnaire hierarchies, extract skip logic,
validations, and generate codebooks. - **[Field Operations, Users, and
Assignments](https://michael-cw.github.io/SurveySolutionsAPIv2/articles/survey_management.md)**:
Batch-create users, generate sample assignments, and assign maps. -
**[Interview Monitoring, Paradata, and Quality
Control](https://michael-cw.github.io/SurveySolutionsAPIv2/articles/interview_monitoring.md)**:
Track interview workflow and monitor field timings. - **[Data Export and
Processing
Pipelines](https://michael-cw.github.io/SurveySolutionsAPIv2/articles/data_export.md)**:
Automate export jobs and generate analysis-ready data tables.
