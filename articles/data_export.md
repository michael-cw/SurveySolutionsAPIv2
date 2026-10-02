# Data Export and Processing Pipelines

## Introduction

Survey Solutions data extraction involves queuing export jobs on the
server, monitoring their progress, downloading the resulting archive,
and transforming raw files into labeled, clean analytical tables.

**`SurveySolutionsAPIv2`** implements the modern **v2 Export API** and
provides high-level pipelines that handle this entire lifecycle
automatically.

------------------------------------------------------------------------

## 1. Supported Export Formats and Options

Survey Solutions supports multiple export formats: - **`Tabular`**:
Tab-delimited flat files (`.tab`). - **`STATA`**: Stata `.dta` files
with variable labels and value labels. - **`SPSS`**: SPSS `.sav`
files. - **`Parquet`**: Modern columnar storage, ideal for big data
workflows. - **`Binary`**: Binary format for images, audio, and
attachments. - **`DDI`**: Data Documentation Initiative XML metadata.

------------------------------------------------------------------------

## 2. Managing Export Processes (v2 API)

The v2 Export API allows fine-grained control over server-side export
jobs.

### Listing Active and Historical Export Jobs

[`suso_getExportList()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getExportList.md)
retrieves export processes across formats and statuses:

``` r

library(SurveySolutionsAPIv2)

# List all export processes in workspace
export_jobs <- suso_getExportList()
```

``` r

# Sample export jobs
demo_exports[, .(JobId, ExportType, Status, HasFile, Progress, StartedAtUtc)]
#>    JobId ExportType    Status HasFile Progress         StartedAtUtc
#>    <int>     <char>    <char>  <lgcl>    <int>               <char>
#> 1:   501    Tabular Completed    TRUE      100 2025-01-22T10:00:00Z
#> 2:   502      STATA Completed    TRUE      100 2025-01-22T10:05:00Z
#> 3:   503    Parquet   Running   FALSE       45 2025-01-22T10:15:00Z
```

### Checking Process Status

To monitor an ongoing job:

``` r

# Poll specific export job
job_status <- suso_getExportProcess(jobid = 503)
print(job_status$Progress)
```

### Canceling or Deleting an Export Job

If an export was initiated with incorrect filters:

``` r

# Cancel running job
suso_cancelExport(jobid = 503)
```

------------------------------------------------------------------------

## 3. Automated End-to-End Export: `suso_export()`

While the low-level functions allow manual job polling,
[`suso_export()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export.md)
wraps the entire workflow into a single command:

    suso_export()
       │
       ├─► 1. Triggers export job on server (v2 API)
       ├─► 2. Polls status with progress indicator
       ├─► 3. Downloads ZIP when complete
       ├─► 4. Unpacks and reads questionnaire metadata
       ├─► 5. Attaches variable and question labels
       ├─► 6. Merges translation files if available
       └─► 7. Returns an exportClass list of data.tables

### Basic Usage

``` r

# Export all completed interviews as Tabular data
survey_data <- suso_export(
  questID         = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version         = 1,
  type            = "Tabular",
  workStatus      = "ApprovedByHeadquarters",
  reloadTimeDiff  = 1,          # Re-download only if older than 1 hour
  addTranslation  = TRUE        # Automatically merge translations
)
```

------------------------------------------------------------------------

## 4. Working with `exportClass` Objects

Data returned by
[`suso_export()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export.md)
is an `exportClass` object, which inherits from `data.table` and retains
rich survey metadata as attributes.

``` r

# Create sample exportClass object
sample_dt <- data.table(
  interview__id = c("int-1", "int-2"),
  hh_size = c(4L, 5L),
  total_exp = c(120.5, 340.0)
)
vlabs <- data.table(
  VariableName = c("hh_size", "total_exp"),
  QuestionText = c("Household Size", "Total Food Expenditure (USD)")
)
exp_obj <- exportClass(sample_dt, varLabels = vlabs)
```

Check class membership:

``` r

is.exportClass(exp_obj)
#> [1] TRUE
```

### Retrieving Metadata with `getinfo()`

[`getinfo()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/getinfo.md)
extracts custom metadata stored on the object:

``` r

# List available attributes
getinfo(exp_obj, "arglist")
#> [1] "hh_size"    "total_exp"  "na_numeric" "isPara"

# Inspect variable labels attached to attributes
getinfo(exp_obj, "hh_size")
#> [1] "Household Size"
getinfo(exp_obj, "total_exp")
#> [1] "Total Food Expenditure (USD)"
```

------------------------------------------------------------------------

## 5. Parallel Processing and Large-Scale Censuses

For national censuses or multi-round panel surveys with hundreds of
thousands of interviews, `SurveySolutionsAPIv2` integrates with the
`future` framework for parallelized exports:

``` r

library(future)
library(doFuture)

# Set up parallel processing with 4 background sessions
plan(multisession, workers = 4)

# Configure concurrency options
suso_set_maxpar_req(100)

# Run exports in parallel across questionnaire versions
# (handled seamlessly by foreach / %dopar% inside the package)
```
