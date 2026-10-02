# Field Operations, Users, and Assignments

## Introduction

Coordinating large-scale field operations involves creating field staff
accounts, provisioning regional workspaces, distributing sample
assignments to enumerators, and managing spatial maps.

**`SurveySolutionsAPIv2`** automates these operational workflows,
enabling seamless integration with sample registries and field
monitoring dashboards.

------------------------------------------------------------------------

## 1. Workspace Administration

Administrators can partition projects into isolated workspaces (e.g. by
region, pilot vs. main survey, or distinct administrative units).

### Creating a New Workspace

``` r

# Create a dedicated workspace for a regional survey
suso_createWorkspace(
  workspace = "central_region",
  displayName = "Central Region Survey 2025"
)
```

### Updating Workspace Details

``` r

# Update display name
suso_updateWorkspace(
  workspace = "central_region",
  displayName = "Central Region (Updated Jan 2025)"
)
```

### Enabling and Disabling Workspaces

When fieldwork for a region concludes, disable the workspace to prevent
unintended edits while keeping historical data intact:

``` r

# Temporarily disable access
suso_enableWorkspace(workspace = "central_region", enable = FALSE)

# Re-enable access
suso_enableWorkspace(workspace = "central_region", enable = TRUE)
```

------------------------------------------------------------------------

## 2. Managing Users and Field Staff

Field hierarchies typically consist of Headquarters, Supervisors, and
Interviewers.

### Batch Creating Enumerators

Rather than creating dozens of enumerator accounts manually via the web
interface,
[`suso_createUSER()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_createUSER.md)
provisions staff in bulk from a standard data frame:

``` r

# Define field staff to create
new_staff <- data.frame(
  Role       = c("Supervisor", "Interviewer", "Interviewer"),
  UserName   = c("supervisor01", "interviewer01", "interviewer02"),
  Password   = c("SecurePass1!", "SecurePass1!", "SecurePass1!"),
  Supervisor = c(NA, "supervisor01", "supervisor01"),
  FullName   = c("Sarah Supervisor", "John Interviewer", "Amina Interviewer"),
  stringsAsFactors = FALSE
)

# Create staff accounts on the server
result <- suso_createUSER(userlist = new_staff)
```

### Querying Field Staff with `UserClass`

To inspect active field staff, retrieve supervisors or interviewers:

``` r

# List all supervisors
supervisors <- suso_getSV()

# List all interviewers and supervisors
all_users <- suso_getUSR()
```

The returned object inherits from `UserClass` (and `data.table`),
enabling direct table operations and custom summaries:

``` r

# Display active staff
demo_users[, .(UserName, Role, FullName, Supervisor)]
#>         UserName        Role           FullName   Supervisor
#>           <char>      <char>             <char>       <char>
#> 1:  supervisor01  Supervisor   Sarah Supervisor         <NA>
#> 2: interviewer01 Interviewer   John Interviewer supervisor01
#> 3: interviewer02 Interviewer  Amina Interviewer supervisor01
#> 4: interviewer03 Interviewer    Ali Interviewer supervisor01
#> 5: interviewer04 Interviewer Fatima Interviewer supervisor01
```

Check class membership:

``` r

is.UserClass(demo_users)
#> [1] TRUE
```

------------------------------------------------------------------------

## 3. Creating and Managing Assignments

Assignments represent fieldwork tasks allocated to specific interviewers
or supervisors.

### Creating Preloaded Assignments

Assignments can be created with pre-filled sample identifiers
(e.g. household ID, cluster, address, or target respondent name):

``` r

# Create assignments for a questionnaire
suso_set_assignments(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  responsible = "interviewer01",
  quantity = 10,
  prefill = list(
    cluster_id = 101,
    region = "Capital"
  )
)
```

### Querying Existing Assignments with `assignmentClass`

[`suso_get_assignments()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_assignments.md)
retrieves all assignments in the active workspace:

``` r

# Retrieve all assignments
assignments <- suso_get_assignments()
```

The returned object is an `assignmentClass` instance:

``` r

# View sample assignments
demo_ass[, .(Id, ResponsibleName, Quantity, InterviewsCount, Archived)]
#>       Id ResponsibleName Quantity InterviewsCount Archived
#>    <int>          <char>    <int>           <int>   <lgcl>
#> 1:   101   interviewer01       10               8    FALSE
#> 2:   102   interviewer01       15              15    FALSE
#> 3:   103   interviewer02       10               7    FALSE
#> 4:   104   interviewer03       12              12    FALSE
#> 5:   105   interviewer04        8               4    FALSE
```

Check class membership:

``` r

is.assignmentClass(demo_ass)
#> [1] TRUE
```

### Reassigning Work in the Field

If an enumerator falls ill or is reassigned, transfer their assignment
to another team member:

``` r

# Reassign assignment #101 to interviewer02
suso_set_assignments(
  assignment_id = 101,
  reassign = TRUE,
  responsible = "interviewer02"
)
```

------------------------------------------------------------------------

## 4. Map Management for Spatial Surveys

For spatial surveys, Survey Solutions supports offline basemaps
(e.g. GeoTIFF, MBTiles, Shapefiles) downloaded to tablets.

### Uploading and Assigning Maps

``` r

# Upload a new offline map
suso_mapupload(
  filePath = "maps/cluster_101_boundary.tif"
)

# Assign map to an interviewer
suso_mapassign(
  fileName = "cluster_101_boundary.tif",
  userName = "interviewer01",
  assignUser = TRUE
)
```

### Generating Spatial Reports

``` r

# Generate a map report of completed interviews
suso_mapreport(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  variable = "gps_dwelling"
)
```
