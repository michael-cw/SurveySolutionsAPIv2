# Changelog

## SurveySolutionsAPIv2 0.1.2

#### New Features & Endpoint Parity

- Completed coverage of all Survey Solutions REST (v1, v2) and GraphQL
  endpoints:
  - **Export Operations**:
    [`suso_getExportList()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getExportList.md)
    to list export jobs,
    [`suso_getExportProcess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getExportProcess.md)
    to check job status, and
    [`suso_cancelExport()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_cancelExport.md)
    to abort running export jobs.
  - **Interview Management**:
    [`suso_assignInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_assignInterview.md)
    to reassign interviews to supervisors/interviewers,
    [`suso_commentInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_commentInterview.md)
    to attach QA comments to specific questions,
    [`suso_deleteInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_deleteInterview.md)
    to remove interviews, and
    [`suso_getInterviewPDF()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getInterviewPDF.md)
    to download completed interview transcripts as PDF files.
  - **Workspace Administration**:
    [`suso_updateWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_updateWorkspace.md)
    to modify existing workspaces,
    [`suso_deleteWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_deleteWorkspace.md)
    to delete workspaces, and
    [`suso_enableWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_enableWorkspace.md)
    to toggle workspace active/disabled status.
  - **Supervisor & User Metadata**:
    [`suso_getSV_info()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getSV_info.md)
    to retrieve detailed supervisor profile information.
  - **Questionnaire Settings**:
    [`suso_questRecordAudio()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_questRecordAudio.md)
    to configure audio recording policies and
    [`suso_questCriticalityLevel()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_questCriticalityLevel.md)
    to configure validation error criticality thresholds.
  - **Server Administration**:
    [`suso_globalNotice()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_globalNotice.md)
    to publish server-wide announcement banners to all active users.
  - **Survey Statistics**:
    [`suso_getStatsQuestionnaires()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getStatsQuestionnaires.md)
    to retrieve aggregate questionnaire completion metrics.

#### Questionnaire Processing

- Updated `suso_getQuestDetails(operation.type = "structure")`

#### Performance & Modernization

- Parallel HTTP request execution using
  [`httr2::req_perform_parallel()`](https://httr2.r-lib.org/reference/req_perform_parallel.html)
  with configurable concurrency limits via
  [`suso_set_maxpar_req()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_maxpar_req.md).

#### Documentation, Vignettes & Website

- Added 5 thematic vignettes covering end-to-end Survey Solutions
  workflows
- Added `pkgdown` companion website

## SurveySolutionsAPIv2 0.1.1

- added system files (parameter: addsysfiles) like interviewer comments,
  errors etc. to suso_export
- smaller bug fixes & improvements
- added option for http connections issue
  [\#8](https://github.com/michael-cw/SurveySolutionsAPIv2/issues/8)

## SurveySolutionsAPIv2 0.1.0

- added new classes: UserClass exportClass and methods, like
  boxplot_summary.exportClass, summaryTable.exportClass
- to have consistency across all function arguments, all functions now
  have server, apiUser, apiPass, as their arguments. This may break some
  code from the old SurveySolutionAPI package, but affects only a few
  functions (see vignette for syntax changes) .
- extended suso_getINT, such that if no sv_id is provided, it will
  return all interviewers in the workspace.
- suso_PwCheck now prints a message and the URL to the console when in
  interactive mode
- suso_getINT_info now covers both interviewer details and retrieval of
  log files (log = T)
- workspace has been added to suso_set_key
- translation can be applied to export data for categorical variables
- export allows to add weights file, so the data is analysis ready
- more informative error messages by using the rlang and the cli package
- implemented parallelisation of requests with the httr2
  req_perform_parallel function, reducing i.e. assignment creation to a
  fraction of a sequential process (use options to customize settings)
- export classes produces (optional) DT summary table and ggplot2
  summary plots
- paradata time difference calculation is now based on milliseconds and
  includes information about questionnaire items, like question type
  etc.
