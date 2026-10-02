# Questionnaires, Structure, and Codebooks

## Introduction

Survey Solutions questionnaires are sophisticated hierarchical documents
comprising sections, multi-level rosters, conditional skip patterns,
inline validation rules, static text instructions, and calculated
variables.

With **`SurveySolutionsAPIv2`**, you can extract the entire
questionnaire specification in milliseconds into clean, normalized flat
tables. This enables automated codebook generation, survey
documentation, and pre-fieldwork verification of routing logic.

------------------------------------------------------------------------

## 1. Extracting Questionnaire Structure

To extract the structure of a questionnaire, supply the
`QuestionnaireId` (GUID), `version`, and specify
`operation.type = "structure"`:

``` r

library(SurveySolutionsAPIv2)

# Extract questionnaire structure
quest_struct <- suso_getQuestDetails(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  operation.type = "structure",
  include_raw = FALSE
)
```

The function returns a named list with **4 structured `data.table`
elements**:

``` r

names(quest_struct)
#> [1] "q"       "val"     "v"       "answers"
```

- **`q`**: Question, roster, and variable metadata.
- **`val`**: Validation rules, expressions, messages, and severity
  labels.
- **`v`**: Backward-compatible alias for `val`.
- **`answers`**: Categorical question answer codes, labels, and category
  mapping.

------------------------------------------------------------------------

## 2. Question Hierarchy and Metadata (`q`)

The `q` table provides an atomic, row-by-row flat representation of
every item in the questionnaire:

``` r

dim(quest_struct$q)
#> [1] 925  29
```

### Inspecting Essential Columns

Key columns include: - **`intID`**: Hierarchical index formatted as
clean dot-separated levels (e.g. `01`, `01.02`, `01.02.04`). -
**`VariableName`**: Variable name used during data export. -
**`QuestionText`**: Formatted question prompt or label. - **`type`**:
Element type (`SingleQuestion`, `NumericQuestion`, `TextQuestion`,
`GpsCoordinateQuestion`, `AreaQuestion`, `Variable`, `StaticText`,
etc.). - **`SectionTitle`** & **`RosterTitle`**: Contextual hierarchy
indicating parent sections and rosters.

``` r

# Display a sample of questions
quest_struct$q[1:6, .(intID, VariableName, type, QuestionText = substr(QuestionText, 1, 40))]
#>     intID VariableName           type                          QuestionText
#>    <char>       <char>         <char>                                <char>
#> 1:     01                       Group                                  <NA>
#> 2:  01.01                  StaticText Household Budget Survey (HBS) 2025/26
#> 3:  01.02      cover01 SingleQuestion                        1. Governorate
#> 4:  01.03      cover02 SingleQuestion                           2. District
#> 5:  01.04      cover03 SingleQuestion                       3. Sub-district
#> 6:  01.05      cover04   TextQuestion                       4. Grid cell ID
```

### Static Text and Calculated Variables

Unlike standard survey tools, Survey Solutions supports static text
blocks and calculated variables (derived formulas).
`SurveySolutionsAPIv2` captures both without data loss:

``` r

# Calculated variables and expressions
calc_vars <- quest_struct$q[type == "Variable", .(VariableName, Expression, VariableType, VariableLabel)]
```

    #>    VariableName                           Expression VariableType
    #>          <char>                               <char>        <int>
    #> 1:     age_greg  /* This calculate the age from the             1
    #> 2:    age_month  CenturyMonthCode(start.Value.Month,            1
    #> 3:       S1Q06a  hhr_brthcal==1?\nage_greg : S1Q06ya            1
    #> 4: final_months hhr_brthcal==1?\nage_month : (S1Q06b            1
    #> 5: S1Q10_over6m                     (S1Q12>6) ? 1:2             1

------------------------------------------------------------------------

## 3. Skip Patterns and Routing Logic

Routing conditions (`ConditionExpression`) define when a question or
entire roster is visible or skipped:

``` r

# Questions with routing conditions
conditions <- quest_struct$q[!is.na(ConditionExpression) & nchar(ConditionExpression) > 0,
                            .(VariableName, ConditionExpression = substr(ConditionExpression, 1, 50))]
head(conditions, 5)
#>      VariableName ConditionExpression
#>            <char>              <char>
#> 1: refusal_reason        consent00==2
#> 2: refusal_others  refusal_reason==96
#> 3:                       consent00==1
#> 4:                       consent00==1
#> 5:            q14        consent00==1
```

Survey designers can use this table to verify that skip patterns
reference valid prior variables before piloting.

------------------------------------------------------------------------

## 4. Validation Rules and Severity (`val`)

The `val` table extracts all Designer validation expressions and their
associated error messages:

``` r

dim(quest_struct$val)
#> [1] 308  10
```

Each validation record provides: - **`VariableName`**: The target
variable being validated. - **`Expression`**: The C# boolean expression
that must evaluate to `true`. - **`Message`**: The message presented to
the enumerator if the expression evaluates to `false`. - **`Severity`**:
`0` for Error (blocks completion), `1` for Warning (can be
acknowledged). - **`SeverityLabel`**: Human-readable `"Error"` or
`"Warning"`.

``` r

# Inspect validation rules
quest_struct$val[1:5, .(VariableName, Expression = substr(Expression, 1, 30), SeverityLabel, Message = substr(Message, 1, 35))]
#>      VariableName                 Expression SeverityLabel
#>            <char>                     <char>        <char>
#> 1:         q6_oth              self.Length>2         Error
#> 2:         q9_oth              self.Length>2         Error
#> 3:     q9_flr_oth self > 6 && self <= 20\r\n         Error
#> 4: refusal_others              self.Length>2         Error
#> 5:            q15            self.Length>=10         Error
#>                                Message
#>                                 <char>
#> 1: Specification is too short. Please 
#> 2: Specification is too short. Please 
#> 3:                                    
#> 4: Specification is very short. Please
#> 5: The reason is not detailed. Please
```

------------------------------------------------------------------------

## 5. Generating Codebooks (`answers`)

For categorical questions (single-select and multi-select), the
`answers` table captures all answer options:

``` r

dim(quest_struct$answers)
#> [1] 1373    8
```

Each record contains: - **`VariableName`**: Parent variable name. -
**`AnswerValue`**: Internal key. - **`AnswerCode`**: Numeric code
exported in datasets. - **`AnswerText`**: Label shown to respondents and
enumerators. - **`CategoriesId`** & **`CategoryName`**: Reusable
category catalogue reference if applicable.

``` r

# View codebook options for a sample question
sample_var <- quest_struct$answers[!is.na(AnswerText)][1, VariableName]
quest_struct$answers[VariableName == sample_var, .(VariableName, AnswerCode, AnswerText)]
#>    VariableName AnswerCode   AnswerText
#>          <char>      <num>       <char>
#> 1:      cover05          1 Sub-cell N°1
#> 2:      cover05          2 Sub-cell N°2
#> 3:      cover05          3 Sub-cell N°3
#> 4:      cover05          4 Sub-cell N°4
```

------------------------------------------------------------------------

## 6. Clean Flat Tables vs Raw JSON

By default, `include_raw = FALSE` produces pure atomic tables with no
list-columns. This ensures direct compatibility with file writers like
[`data.table::fwrite()`](https://rdrr.io/pkg/data.table/man/fwrite.html):

``` r

# Export directly to CSV without list-column serialization errors
data.table::fwrite(quest_struct$q, "questionnaire_metadata.csv")
data.table::fwrite(quest_struct$answers, "questionnaire_codebook.csv")
```

If you require low-level access to the original JSON node definitions
(such as custom properties or raw translation tables), set
`include_raw = TRUE`:

``` r

# Retain raw ..JSON list column
raw_struct <- suso_getQuestDetails(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  operation.type = "structure",
  include_raw = TRUE
)

# Access raw properties of the 10th node
raw_node <- raw_struct$q$..JSON[[10]]
```

------------------------------------------------------------------------

## 7. Questionnaire Settings: Audio & Criticality

### Audio Audit Recording

Survey Solutions supports background audio recording audits for quality
assurance:

``` r

# Query current audio recording setting
audio_setting <- suso_questRecordAudio(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1
)

# Enable background audio recording
suso_questRecordAudio(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  enabled = TRUE
)
```

### Criticality Level

You can programmatically retrieve or enforce validation criticality:

``` r

# Get current criticality level
suso_questCriticalityLevel(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1
)

# Set criticality level to Warn
suso_questCriticalityLevel(
  questID = "17a9fa22-1ef6-46d2-8c30-426aa876f273",
  version = 1,
  level = "Warn"
)
```
