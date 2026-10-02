test_that("input validation helpers work correctly", {
  # .ws_default
  expect_equal(SurveySolutionsAPIv2:::.ws_default(NULL), "primary")
  expect_equal(SurveySolutionsAPIv2:::.ws_default("custom_ws"), "custom_ws")

  # .checkNum
  expect_silent(SurveySolutionsAPIv2:::.checkNum(123))
  expect_silent(SurveySolutionsAPIv2:::.checkNum(45.6))
  expect_error(SurveySolutionsAPIv2:::.checkNum("not_numeric"), class = "rlang_error")

  # .checkUUIDFormat
  valid_uuid_hyphen <- "12345678-1234-1234-1234-1234567890ab"
  valid_uuid_no_hyphen <- "123456781234123412341234567890ab"
  expect_silent(SurveySolutionsAPIv2:::.checkUUIDFormat(valid_uuid_hyphen))
  expect_silent(SurveySolutionsAPIv2:::.checkUUIDFormat(valid_uuid_no_hyphen))
  expect_error(SurveySolutionsAPIv2:::.checkUUIDFormat("invalid-uuid"), class = "rlang_error")

  # .checkIntKeyformat
  expect_silent(SurveySolutionsAPIv2:::.checkIntKeyformat("12-34-56-78"))
  expect_error(SurveySolutionsAPIv2:::.checkIntKeyformat("12-34-56"))

  # .checkEmailFormat
  expect_silent(SurveySolutionsAPIv2:::.checkEmailFormat("user@example.com"))
  expect_error(SurveySolutionsAPIv2:::.checkEmailFormat("not_an_email"), class = "rlang_error")

  # .check_basics
  expect_error(SurveySolutionsAPIv2:::.check_basics(NULL, NULL, NULL, NULL), class = "rlang_error")
  expect_silent(SurveySolutionsAPIv2:::.check_basics(NULL, "https://demo.mysurvey.solutions", "user", "pass"))
  expect_silent(SurveySolutionsAPIv2:::.check_basics("mytoken", "https://demo.mysurvey.solutions", NULL, NULL))
})
