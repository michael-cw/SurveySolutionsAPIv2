## Resubmission
This is a resubmission addressing the feedback from Leonore Hochhauser:

* Quoted all package names, software names, and API names in single quotes in `Title` and `Description` in `DESCRIPTION` (`'Survey Solutions'`, `'REST'`, `'GraphQL'`, `'shiny'`, `'httr2'`, `'httr'`), respecting case sensitivity.
* Fixed unexecutable comments/output lines in `man/suso_get_assignments.Rd` and `man/suso_getAllInterviewQuestionnaire.Rd`.
* Replaced all occurrences of `T` and `F` with `TRUE` and `FALSE` across all function defaults, source files in `R/`, and `@examples` in `man/`.
* Unwrapped examples that do not require an active server connection and run in `< 5` seconds (`suso_set_key`, `suso_get_default_key`, `getinfo`, `boxplot_summary`, `summaryTable`), and replaced `\dontrun{}` with `\donttest{}` (guarded by `suso_PwCheck() == 200`) for API functions that require a live 'Survey Solutions' server and credentials.
* Replaced unsuppressed `cat()` calls in `R/utils_para.R`, `R/httr2_suso_api_paradata.R`, and `R/httr2_suso_export_data.R` with `message()` (and guarded status messages with `if (verbose)`).

## Test environments
* local macOS (aarch64, Apple Silicon), R 4.3.1
* win-builder (R-release and R-devel)
* GitHub Actions (ubuntu-latest, macOS-latest, windows-latest)

## R CMD check results

0 errors | 0 warnings | 1 note

* Note: "New submission". This is a new submission to CRAN.
