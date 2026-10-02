## Test environments
* local macOS (aarch64, Apple Silicon), R 4.3.1
* win-builder (R-release and R-devel)
* GitHub Actions (ubuntu-latest, macOS-latest, windows-latest)

## R CMD check results

0 errors | 0 warnings | 1 note

* Note: "New submission". This is a new submission to CRAN.
* All functions communicate via HTTP to Survey Solutions REST/GraphQL API servers. Network-dependent tests and examples are guarded by offline checks or marked with \dontrun{} in accordance with CRAN repository policy.
