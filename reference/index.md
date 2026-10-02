# Package index

## Authentication & Credentials

Functions for setting, checking, and managing Survey Solutions
credentials.

- [`suso_set_key()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_key.md)
  : Set all credentials at once
- [`suso_get_api_key()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_api_key.md)
  : Get credentials
- [`suso_get_default_key()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_default_key.md)
  : Checks if credentials are present
- [`suso_clear_keys()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_clear_keys.md)
  : Clear Credentials
- [`suso_keys()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_keys.md)
  : Survey Solutions API credentials
- [`suso_PwCheck()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_PwCheck.md)
  : Utility function to check if credentials are correct
- [`suso_set_workspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_workspace.md)
  : Convenience function to switch workspace

## Workspace Administration

Create, inspect, update, and enable/disable multi-tenant workspaces.

- [`suso_getWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getWorkspace.md)
  : Survey Solutions API call for workspace information
- [`suso_createWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_createWorkspace.md)
  : Survey Solutions API call to create workspace
- [`suso_updateWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_updateWorkspace.md)
  : Update workspace details
- [`suso_deleteWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_deleteWorkspace.md)
  : Delete a workspace
- [`suso_enableWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_enableWorkspace.md)
  : Enable or disable a workspace
- [`suso_assignWorkspace()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_assignWorkspace.md)
  : Survey Solutions API call to assign workspace (!! WORKS ONLY WITH
  ADMIN CREDENTIALS)

## Questionnaires & Survey Design

Inspect questionnaire specifications, routing, validation rules,
codebooks, and settings.

- [`suso_getQuestDetails()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getQuestDetails.md)
  : Survey Solutions API call for questionnaire
- [`suso_questRecordAudio()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_questRecordAudio.md)
  : Survey Solutions API call for questionnaire audio recording setting
- [`suso_questCriticalityLevel()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_questCriticalityLevel.md)
  : Survey Solutions API call for questionnaire criticality level
  setting

## User & Field Staff Management

Create, query, and manage supervisors, interviewers, and headquarters
staff.

- [`suso_createUSER()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_createUSER.md)
  : Survey Solutions API call for User Creation
- [`suso_getUSR()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getUSR.md)
  : Survey Solutions API call for info on any user
- [`suso_getSV()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getSV.md)
  : Survey Solutions API call for list of supervisors
- [`suso_getSV_info()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getSV_info.md)
  : Survey Solutions API call for supervisor info
- [`suso_archUSR()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_archUSR.md)
  : Survey Solutions API call (un-) archive user

## Assignment Operations

Create, query, and reassign sample assignments with preloaded data.

- [`suso_set_assignments()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_assignments.md)
  : Survey Solutions API call for assignment manipulation
- [`suso_get_assignments()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_assignments.md)
  : Survey Solutions API call for assignment list
- [`suso_createASS()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_createASS.md)
  : Survey Solutions API call for Assignment Creation

## Interview Workflow & Quality Control

Track interviews, approve/reject, leave comments, reassign, and download
PDF transcripts.

- [`suso_getAllInterviewQuestionnaire()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getAllInterviewQuestionnaire.md)
  : Survey Solutions API call to retrieve all interviews for a specific
  questionnaire
- [`suso_getINT()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getINT.md)
  : Survey Solutions API call for list of interviewers
- [`suso_getINT_info()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getINT_info.md)
  : Survey Solutions API call for info on interviewers
- [`suso_getAllAnswerInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getAllAnswerInterview.md)
  : Survey Solutions API call to retrieve all answers for a specific
  interview
- [`suso_getAllHistoryInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getAllHistoryInterview.md)
  : Get all history for a specific interview
- [`suso_assignInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_assignInterview.md)
  : Assign interview to interviewer or supervisor
- [`suso_commentInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_commentInterview.md)
  : Leave a comment on a question in an interview
- [`suso_patchApproveInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_patchApproveInterview.md)
  : Approve interviews either as supervisor or as headquarter.
- [`suso_patchRejectInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_patchRejectInterview.md)
  : Reject interviews either as supervisor or as headquarter.
- [`suso_deleteInterview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_deleteInterview.md)
  : Delete an interview
- [`suso_getInterviewPDF()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getInterviewPDF.md)
  : Download interview PDF transcript
- [`suso_createCALEV()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/calendarevent.md)
  [`suso_updateCALEV()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/calendarevent.md)
  [`suso_delCALEV()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/calendarevent.md)
  : Create, update or delete a calendar event

## Data Export (v2 API)

End-to-end export pipelines, progress monitoring, and archive handling.

- [`suso_export()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export.md)
  : Survey Solutions API call to generate and download the data
- [`suso_getExportList()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getExportList.md)
  : Survey Solutions API call to list export processes
- [`suso_getExportProcess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getExportProcess.md)
  : Survey Solutions API call to get detailed information about an
  export process
- [`suso_cancelExport()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_cancelExport.md)
  : Survey Solutions API call to cancel an export process

## Paradata Processing

Export, parse, and analyze event paradata, pauses, and spatial traces.

- [`suso_export_paradata()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_export_paradata.md)
  : Export Survey Solutions paradata

## Maps & Spatial Management

Upload offline basemaps, assign maps to interviewers, and generate
spatial reports.

- [`suso_mapupload()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_mapupload.md)
  : Upload map to server
- [`suso_mapinfo()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_mapinfo.md)
  : Receive maps currently uploaded to the server
- [`suso_mapassign()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_mapassign.md)
  : Assigns/Unassign a map to a user
- [`suso_deletemap()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_deletemap.md)
  : Delete Map from Server
- [`suso_mapreport()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_mapreport.md)
  : Create a Map Report

## Statistics & Server Settings

Question response statistics and global headquarters notices.

- [`suso_get_stats()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_stats.md)
  : Survey Solutions API call for Summary Tables
- [`suso_getStatsQuestionnaires()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getStatsQuestionnaires.md)
  : Survey Solutions API call for questionnaires with statistics
- [`suso_getQuestionsQuestionnaire()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_getQuestionsQuestionnaire.md)
  : Survey Solutions API call for questions and responses from single
  questionnaire
- [`suso_get_stats_interview()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_get_stats_interview.md)
  : Get statistics for interview
- [`suso_globalNotice()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_globalNotice.md)
  : Survey Solutions API call for Headquarters Global Notice settings

## Classes & S3 Methods

Custom data classes extending data.table with rich survey metadata.

- [`UserClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/UserClass.md)
  : User Classes & Methods
- [`is.UserClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/is.UserClass.md)
  : Function to check if an object is of class UserClass
- [`assignmentClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/assignmentClass.md)
  : Assignment Classes & Methods
- [`is.assignmentClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/is.assignmentClass.md)
  : Function to check if an object is of class assignmentClass
- [`exportClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/exportClass.md)
  : Export Classes & Methods
- [`is.exportClass()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/is.exportClass.md)
  : Function to check if an object is of class exportClass
- [`getinfo()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/getinfo.md)
  : assignmentClass methods
- [`summaryTable()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/summaryTable.md)
  : S3 method to create a summary table of numeric variables for an
  exportClass object
- [`summaryTable(`*`<UserClass>`*`)`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/summaryTable.UserClass.md)
  : S3 method to create a summary table of users for UserClass object
- [`boxplot_summary()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/boxplot_summary.md)
  : S3 method to create a box plot of numeric variables for an
  exportClass object

## Package Options & Shiny Helpers

Configuration options for parallel processing and Shiny notifications.

- [`suso.options`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso.options.md)
  : Configuration options used for the SurveySolutionsAPIv2 package
- [`suso_set_maxpar_req()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso_set_maxpar_req.md)
  : Convenience Function to modify the maximum number of parallel
  requests option
- [`suso_set_pwcheck_mess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso-shiny-messages.md)
  [`suso_set_prog_mess()`](https://michael-cw.github.io/SurveySolutionsAPIv2/reference/suso-shiny-messages.md)
  : Convenience functions to modify user notification text
