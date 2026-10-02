test_that("HTTP URL builder constructs proper URLs", {
  url_basic <- SurveySolutionsAPIv2:::.baseurl_baseauth(
    server = "https://demo.mysurvey.solutions",
    workspace = "primary",
    apiUser = "testuser",
    apiPass = "testpass",
    api = "assignments",
    version = "v1"
  )
  expect_equal(url_basic$url, "https://demo.mysurvey.solutions/primary/api/v1/assignments")

  url_token <- SurveySolutionsAPIv2:::.baseurl_token(
    server = "https://demo.mysurvey.solutions",
    workspace = "primary",
    token = "test_token",
    api = "assignments",
    version = "v1"
  )
  expect_equal(url_token$url, "https://demo.mysurvey.solutions/primary/api/v1/assignments")

  # Global URL (workspace = NULL)
  url_global <- SurveySolutionsAPIv2:::.baseurl_baseauth(
    server = "https://demo.mysurvey.solutions",
    workspace = NULL,
    apiUser = "testuser",
    apiPass = "testpass",
    api = "workspaces",
    version = "v1"
  )
  expect_equal(url_global$url, "https://demo.mysurvey.solutions/api/v1/workspaces")
})

test_that("API functions validate inputs properly before making requests", {
  # suso_globalNotice
  expect_error(
    suso_globalNotice(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                      action = "set", message = NULL),
    class = "rlang_error"
  )

  # suso_questCriticalityLevel
  expect_error(
    suso_questCriticalityLevel(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                               questID = NULL, version = 1),
    class = "rlang_error"
  )
  expect_error(
    suso_questCriticalityLevel(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                               questID = "invalid-uuid", version = 1),
    class = "rlang_error"
  )

  # suso_questRecordAudio
  expect_error(
    suso_questRecordAudio(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                          questID = "12345678-1234-1234-1234-1234567890ab", version = 1, enabled = "not_logical"),
    class = "rlang_error"
  )

  # suso_getExportProcess & suso_cancelExport
  expect_error(
    suso_getExportProcess(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p", jobid = NULL),
    class = "rlang_error"
  )
  expect_error(
    suso_cancelExport(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p", jobid = "not_num"),
    class = "rlang_error"
  )

  # suso_updateWorkspace & suso_deleteWorkspace
  expect_error(
    suso_updateWorkspace(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p", workspace = NULL),
    class = "rlang_error"
  )
  expect_error(
    suso_deleteWorkspace(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p", workspace = NULL),
    class = "rlang_error"
  )

  # suso_deleteInterview
  expect_error(
    suso_deleteInterview(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p", intID = "bad-id"),
    class = "rlang_error"
  )

  # suso_assignInterview
  expect_error(
    suso_assignInterview(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                         intID = "12345678-1234-1234-1234-1234567890ab", userId = NULL),
    class = "rlang_error"
  )

  # suso_commentInterview
  expect_error(
    suso_commentInterview(server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                          intID = "12345678-1234-1234-1234-1234567890ab", comment = ""),
    class = "rlang_error"
  )
})
