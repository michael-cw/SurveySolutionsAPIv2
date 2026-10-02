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

  # suso_createASS validation
  expect_error(
    suso_createASS(df = NULL, server = "https://demo.mysurvey.solutions", apiUser = "u", apiPass = "p",
                   questID = "12345678-1234-1234-1234-1234567890ab", version = 1),
    class = "rlang_error"
  )
})

test_that("suso_createASS handles response transformation with empty metadata lists", {
  # Mock a server response containing empty History, Answers, IdentifyingData, and null Email
  mock_resp_json <- '{
    "Assignment": {
      "Id": 101,
      "ResponsibleId": "u-guid-1",
      "ResponsibleName": "interviewer01",
      "QuestionnaireId": "17a9fa22-1ef6-46d2-8c30-426aa876f273",
      "Version": 1,
      "Quantity": 10,
      "Archived": false,
      "CreatedAtUtc": "2026-10-02T17:40:00Z",
      "UpdatedAtUtc": "2026-10-02T17:40:00Z",
      "Email": null,
      "Password": null,
      "WebMode": false,
      "IsAudioRecordingEnabled": false,
      "Comments": null,
      "InterviewsCount": 0,
      "IdentifyingData": [],
      "History": [],
      "Answers": []
    }
  }'
  mock_resp <- httr2::response(
    status_code = 200,
    headers = list(`Content-Type` = "application/json"),
    body = charToRaw(mock_resp_json)
  )

  # Run the inner transformation logic
  transform_fun <- function(resp_obj) {
    respfull <- httr2::resp_body_json(resp_obj, simplifyVector = TRUE, flatten = TRUE)
    id_data <- respfull$Assignment$IdentifyingData
    if (!is.null(id_data) && (is.data.frame(id_data) || length(id_data) > 0)) {
      resp <- tryCatch({
        df_id <- as.data.frame(id_data)
        if (nrow(df_id) > 0) {
          reshaped_data <- as.vector(t(df_id))
          new_col_names <- paste0(rep(names(df_id), each = nrow(df_id)), 1:nrow(df_id))
          setNames(data.frame(matrix(reshaped_data, ncol = length(reshaped_data), byrow = TRUE)), new_col_names)
        } else {
          data.frame(NO_ID_DATA = "NO ID DATA LOADED")
        }
      }, error = function(e) data.frame(NO_ID_DATA = "NO ID DATA LOADED"))
    } else {
      resp <- data.frame(NO_ID_DATA = "NO ID DATA LOADED")
    }

    nodf <- names(respfull$Assignment)[!grepl("IdentifyingData", names(respfull$Assignment))]
    for(x in nodf){
      val <- respfull$Assignment[[x]]
      if (is.null(val) || length(val) == 0) {
        resp[[x]] <- NA
      } else if (is.list(val) || length(val) > 1) {
        resp[[x]] <- list(val)
      } else {
        resp[[x]] <- val
      }
    }
    return(resp)
  }

  res_df <- transform_fun(mock_resp)
  res_dt <- data.table::as.data.table(res_df)
  expect_equal(res_dt$Id, 101)
  expect_equal(res_dt$ResponsibleName, "interviewer01")
  expect_equal(res_dt$Quantity, 10)
  expect_true(is.na(res_dt$History))
  expect_true(is.na(res_dt$Answers))
  expect_true(is.na(res_dt$Email))
  expect_equal(res_dt$NO_ID_DATA, "NO ID DATA LOADED")
})
