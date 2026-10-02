## Test environments
* local macOS (aarch64, Apple Silicon), R 4.3.1
* win-builder (devel and release)
* GitHub Actions (ubuntu-latest, macOS-latest, windows-latest)

## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new release.
* All functions communicate via HTTP to Survey Solutions REST/GraphQL API servers. Network-dependent tests and examples are guarded by offline checks or marked with \dontrun{} in accordance with CRAN repository policy.
