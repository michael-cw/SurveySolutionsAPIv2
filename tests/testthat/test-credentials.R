test_that("credential management functions work correctly", {
  # Save existing env vars
  old_server <- Sys.getenv("SUSO_SERVER", unset = NA)
  old_user <- Sys.getenv("SUSO_USER", unset = NA)
  old_pass <- Sys.getenv("SUSO_PASSWORD", unset = NA)
  old_ws <- Sys.getenv("SUSO_WORKSPACE", unset = NA)

  on.exit({
    if (!is.na(old_server)) Sys.setenv(SUSO_SERVER = old_server) else Sys.unsetenv("SUSO_SERVER")
    if (!is.na(old_user)) Sys.setenv(SUSO_USER = old_user) else Sys.unsetenv("SUSO_USER")
    if (!is.na(old_pass)) Sys.setenv(SUSO_PASSWORD = old_pass) else Sys.unsetenv("SUSO_PASSWORD")
    if (!is.na(old_ws)) Sys.setenv(SUSO_WORKSPACE = old_ws) else Sys.unsetenv("SUSO_WORKSPACE")
  })

  # Set keys
  suso_set_key(suso_server = "https://demo.mysurvey.solutions",
               suso_user = "api_user_test",
               suso_password = "secret123",
               workspace = "test_workspace")

  expect_equal(suso_get_api_key("susoServer"), "https://demo.mysurvey.solutions/")
  expect_equal(suso_get_api_key("susoUser"), "api_user_test")
  expect_equal(suso_get_api_key("susoPass"), "secret123")
  expect_equal(suso_get_api_key("workspace"), "test_workspace")

  # suso_keys returns suso_api object
  keys_obj <- suso_keys()
  expect_s3_class(keys_obj, "suso_api")
  expect_equal(keys_obj$suso$susoUser, "api_user_test")

  # suso_clear_keys should remove them
  suso_clear_keys()
  expect_true(is.na(suso_get_api_key("susoServer")))
  expect_true(is.na(suso_get_api_key("susoUser")))
})
