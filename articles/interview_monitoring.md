# Interview Monitoring, Paradata, and Quality Control

## Introduction

Continuous quality control (QC) and high-frequency checks (HFC) are
vital to preventing non-sampling errors during fieldwork.

**`SurveySolutionsAPIv2`** equips survey teams with real-time tools
to: 1. Monitor interview workflow statuses. 2. Take supervisory actions
(commenting, approving, rejecting, reassigning). 3. Query real-time
response distributions. 4. Process granular event paradata (timings,
pauses, and spatial traces).

------------------------------------------------------------------------

## 1. Tracking Interview Progress

Every interview in Survey Solutions moves through a defined lifecycle:

    [Created / Assigned]
            │
            ▼
       [Completed] ──► [Supervisor Review]
                              │
                 ┌────────────┴────────────┐
                 ▼                         ▼
       [RejectedBySupervisor]    [ApprovedBySupervisor]
                 │                         │
                 ▼                         ▼
       (Back to enumerator)       [Headquarters Review]
                                           │
                              ┌────────────┴────────────┐
                              ▼                         ▼
                   [RejectedByHeadquarters]  [ApprovedByHeadquarters]

### Querying Interviews by Status

[`suso_getAllInterviewQuestionnaire()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getAllInterviewQuestionnaire.md)
retrieves all interviews matching target criteria:

``` r

# Get all completed interviews awaiting review
completed_ints <- suso_getAllInterviewQuestionnaire(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  workStatus = "Completed"
)
```

The resulting table provides status, error counts, enumerator
assignment, and last modification timestamp:

``` r

# Sample interview statuses
demo_ints[, .(InterviewId = substr(InterviewId, 1, 13), ResponsibleName, Status, ErrorsCount)]
#>      InterviewId ResponsibleName                 Status ErrorsCount
#>           <char>          <char>                 <char>       <int>
#> 1: a1b2c3d4-0001   interviewer01              Completed           0
#> 2: a1b2c3d4-0002   interviewer01   ApprovedBySupervisor           0
#> 3: a1b2c3d4-0003   interviewer01   RejectedBySupervisor           2
#> 4: a1b2c3d4-0004   interviewer02    InterviewerAssigned           1
#> 5: a1b2c3d4-0005   interviewer03 ApprovedByHeadquarters           0
```

``` r

# Summary breakdown of interview statuses
demo_ints[, .N, by = Status]
#>                    Status     N
#>                    <char> <int>
#> 1:              Completed     1
#> 2:   ApprovedBySupervisor     1
#> 3:   RejectedBySupervisor     1
#> 4:    InterviewerAssigned     1
#> 5: ApprovedByHeadquarters     1
```

------------------------------------------------------------------------

## 2. Supervisory Actions and Audit

When high-frequency checks flag inconsistencies, supervisors or HQ
monitors can interact directly with the interview.

### Leaving Comments on Question Responses

Comments can be attached directly to a specific variable with optional
feedback:

``` r

# Leave a comment on the respondent age variable
suso_commentInterview(
  intID    = "a1b2c3d4-0003-4000-8000-000000000003",
  variable = "age",
  comment  = "Reported age (14) is inconsistent with marital status (Married). Please verify with respondent."
)
```

### Rejecting and Approving Interviews

``` r

# Reject back to supervisor with explanation
suso_patchRejectInterview(
  intID   = "a1b2c3d4-0003-4000-8000-000000000003",
  comment = "Multiple validation errors require re-visiting the household."
)

# Approve interview at Headquarters
suso_patchApproveInterview(
  intID   = "a1b2c3d4-0001-4000-8000-000000000001",
  comment = "Passed all automated consistency audits."
)
```

### Downloading Interview PDF Transcripts

For formal documentation or audit trails, download the full interview
transcript as a formatted PDF:

``` r

# Download completed transcript
pdf_file <- suso_getInterviewPDF(
  intID = "a1b2c3d4-0001-4000-8000-000000000001",
  path  = "audits/interview_0001_transcript.pdf"
)
```

------------------------------------------------------------------------

## 3. Real-Time Question Statistics

To detect enumerator fabrication or question misinterpretation early,
[`suso_get_stats()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_stats.md)
queries live response distributions directly from the server:

``` r

# Query response distribution for a categorical question
q_stats <- suso_get_stats(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  qQuest  = "household_head_gender"
)
```

------------------------------------------------------------------------

## 4. Paradata Processing

Paradata captures timestamped events triggered during data collection:
question focus, response edits, validation messages, and pauses.

### Exporting Paradata with `suso_export_paradata()`

[`suso_export_paradata()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export_paradata.md)
downloads and structures paradata events into an enriched `exportClass`
table:

``` r

# Export paradata for a questionnaire
para <- suso_export_paradata(
  questID           = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version           = 1,
  onlyActiveEvents  = TRUE,
  reloadTimeDiff    = 0
)
```

### Key QC Metrics from Paradata

1.  **Active Interview Duration**: Calculates total active time
    excluding breaks (default break threshold is 120 seconds).
2.  **Response Latency**: Measures elapsed seconds per question to
    identify speeders or difficult modules.
3.  **GPS Coordinates**: Automatically extracts geographic coordinates
    associated with paradata events to verify that interviews occurred
    within assigned sample clusters.
