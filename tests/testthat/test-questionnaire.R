test_that(".suso_transform_fullValid_q parses questionnaire structure correctly", {
  mock_doc <- list(
    Id = "11111111-2222-3333-4444-555555555555",
    LastEntryDate = "2025-01-01T12:00:00Z",
    Categories = list(
      list(Id = "cat1", Name = "Category 1")
    ),
    Children = list(
      list(
        `$type` = "Section",
        Title = "Section A",
        Children = list(
          list(
            `$type` = "SingleQuestion",
            VariableName = "q1",
            PublicKey = "pk-q1",
            QuestionText = "Question 1?",
            Instructions = "Select one answer",
            ConditionExpression = "1 == 1",
            Answers = list(
              list(AnswerValue = "1", AnswerText = "Yes", AnswerCode = 1),
              list(AnswerValue = "2", AnswerText = "No", AnswerCode = 2)
            ),
            ValidationConditions = list(
              list(Expression = "self > 0", Message = "Must be positive", Severity = 0),
              list(Expression = "self < 100", Message = "Usually under 100", Severity = 1)
            )
          ),
          list(
            `$type` = "StaticText",
            Text = "Introductory text for section",
            PublicKey = "pk-static"
          ),
          list(
            `$type` = "Variable",
            Name = "calc_var",
            Expression = "q1 * 2",
            Type = 2L,
            Label = "Calculated Variable",
            DoNotExport = TRUE
          ),
          list(
            `$type` = "AreaQuestion",
            VariableName = "plot_area",
            Properties = list(GeometryType = 0L)
          ),
          list(
            `$type` = "SingleQuestion",
            VariableName = "cat_q",
            CategoriesId = "cat1"
          )
        )
      )
    )
  )

  # Default include_raw = FALSE
  res_clean <- .suso_transform_fullValid_q(mock_doc, include_raw = FALSE)

  expect_named(res_clean, c("q", "val", "v", "answers"))
  expect_equal(nrow(res_clean$q), 6)
  expect_false("..JSON" %in% names(res_clean$q))
  expect_equal(res_clean$val, res_clean$v)

  # Check StaticText
  expect_equal(res_clean$q[PublicKey == "pk-static", QuestionText], "Introductory text for section")

  # Check Variable fields
  expect_equal(res_clean$q[VariableName == "calc_var", Expression], "q1 * 2")
  expect_equal(res_clean$q[VariableName == "calc_var", VariableType], 2L)
  expect_equal(res_clean$q[VariableName == "calc_var", VariableLabel], "Calculated Variable")
  expect_true(res_clean$q[VariableName == "calc_var", DoNotExport])

  # Check intID has no NA string
  expect_false(any(grepl("NA", res_clean$q$intID)))
  expect_equal(res_clean$q$intID[1], "01")
  expect_equal(res_clean$q$intID[2], "01.01")

  # Check validation table
  expect_equal(nrow(res_clean$val), 2)
  expect_equal(res_clean$val$SeverityLabel, c("Error", "Warning"))
  expect_equal(res_clean$val$Message, c("Must be positive", "Usually under 100"))

  # Check answers table
  expect_equal(nrow(res_clean$answers), 3)
  expect_equal(res_clean$answers[VariableName == "q1", AnswerText], c("Yes", "No"))
  expect_equal(res_clean$answers[VariableName == "cat_q", CategoryName], "Category 1")

  # Check data.table::fwrite works without error
  tmp_csv <- tempfile(fileext = ".csv")
  expect_silent(data.table::fwrite(res_clean$q, tmp_csv))
  expect_true(file.exists(tmp_csv))
  unlink(tmp_csv)

  # Check include_raw = TRUE
  res_raw <- .suso_transform_fullValid_q(mock_doc, include_raw = TRUE)
  expect_true("..JSON" %in% names(res_raw$q))
  expect_equal(length(res_raw$q$..JSON), 6)

  # Check .questionnaire_gpsquestion works without ..JSON
  gps <- .questionnaire_gpsquestion(res_clean$q)
  expect_equal(gps[VariableName == "plot_area", type1], "POLY")
})

test_that(".suso_transform_fullValid_q handles null and empty inputs gracefully", {
  null_res <- .suso_transform_fullValid_q(NULL)
  expect_named(null_res, c("q", "val", "v", "answers"))
  expect_equal(nrow(null_res$q), 0)
  expect_equal(nrow(null_res$val), 0)
  expect_equal(nrow(null_res$v), 0)
  expect_equal(nrow(null_res$answers), 0)

  empty_doc <- list(Id = "empty-id", Children = list())
  empty_res <- .suso_transform_fullValid_q(empty_doc)
  expect_equal(nrow(empty_res$q), 0)
})
