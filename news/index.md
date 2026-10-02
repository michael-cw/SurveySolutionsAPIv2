# Changelog

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
