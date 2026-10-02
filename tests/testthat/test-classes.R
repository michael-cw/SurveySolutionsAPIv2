test_that("S3 classes and methods work correctly", {
  # assignmentClass
  ass_data <- data.table::data.table(
    Id = 1:2,
    ResponsibleName = c("supervisor1", "interviewer1"),
    ResponsibleId = c("uuid1", "uuid2"),
    QuestionnaireId = "quest-uuid",
    Version = 1,
    Status = c("ApprovedBySupervisor", "Completed")
  )
  ass_obj <- SurveySolutionsAPIv2:::assignmentClass(list(Assignments = ass_data, TotalCount = 2))
  expect_s3_class(ass_obj, "assignmentClass")
  expect_s3_class(ass_obj, "data.table")

  info_ass <- getinfo(ass_obj, "arglist")
  expect_true("totalcount" %in% info_ass)

  # UserClass
  usr_data <- data.table::data.table(
    UserId = c("u1", "u2"),
    UserName = c("john", "jane"),
    Role = c("Supervisor", "Interviewer"),
    IsArchived = c(FALSE, FALSE)
  )
  usr_obj <- SurveySolutionsAPIv2:::UserClass(list(Users = usr_data, TotalCount = 2))
  expect_s3_class(usr_obj, "UserClass")
  expect_s3_class(usr_obj, "data.table")

  info_usr <- getinfo(usr_obj, "arglist")
  expect_true("totalcount" %in% info_usr)

  # exportClass
  exp_data <- data.table::data.table(
    interview__id = c("int1", "int2"),
    q1 = c(1, 2)
  )
  exp_labels <- data.table::data.table(VariableName = "q1", QuestionText = "Question 1")
  exp_obj <- SurveySolutionsAPIv2:::exportClass(exp_data, varLabels = exp_labels)
  expect_s3_class(exp_obj, "exportClass")
  expect_s3_class(exp_obj, "data.table")
  info_exp <- getinfo(exp_obj, "arglist")
  expect_type(info_exp, "character")
})
