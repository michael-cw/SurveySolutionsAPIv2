#' Helper functions to transform list of questionnair structure to single data.table with all variables
#'
#' Uses tidyjson package
#'
#' \code{suso_transform_fullMeta} transforms the list containing the structure (\emph{operation.type = structure})
#' is transformed into a single data.table
#' with all variable names, types etc.. This also works with json strings manually exported from the server.
#'
#'
#' @param input returned by \code{suso_getQuestDetails} structure operation
#'
#'
#' @return data.table with all variables in the questionnaire
#'
#' @keywords internal
#' @noRd
#'

.suso_transform_fullValid_q <- function(input = NULL, include_raw = FALSE) {
  if (is.null(input)) {
    return(list(
      q = data.table::data.table(),
      val = data.table::data.table(),
      v = data.table::data.table(),
      answers = data.table::data.table()
    ))
  }

  if (inherits(input, "tbl_json")) {
    doc <- input$..JSON[[1]]
  } else if (is.character(input)) {
    if (file.exists(input)) {
      doc <- jsonlite::fromJSON(input, simplifyVector = FALSE)
    } else {
      doc <- jsonlite::fromJSON(input, simplifyVector = FALSE)
    }
  } else if (is.list(input) && "Children" %in% names(input)) {
    doc <- input
  } else if (is.list(input) && "$type" %in% names(input)) {
    doc <- input
  } else {
    cli::cli_abort(c("x" = "Invalid input format for questionnaire document."))
  }

  quest_id <- doc$Id %||% NA_character_
  last_entry <- doc$LastEntryDate %||% NA_character_

  cat_map <- list()
  if (!is.null(doc$Categories)) {
    for (cat in doc$Categories) {
      if (!is.null(cat$Id) && !is.null(cat$Name)) {
        cat_map[[cat$Id]] <- cat$Name
      }
    }
  }

  q_list <- list()
  val_list <- list()
  ans_list <- list()
  max_depth <- 0

  traverse <- function(node, indices = integer(0), cur_section = NA_character_,
                       cur_roster_var = NA_character_, cur_roster_title = NA_character_) {
    depth <- length(indices)
    if (depth > max_depth) max_depth <<- depth

    t <- node[["$type"]] %||% "Unknown"
    is_roster <- isTRUE(node[["IsRoster"]])
    title <- node[["Title"]] %||% NA_character_
    var_name <- node[["VariableName"]] %||% node[["Name"]] %||% NA_character_

    # Update hierarchy context
    if (depth == 1) {
      cur_section <- title
    }
    if (is_roster) {
      cur_roster_var <- var_name
      cur_roster_title <- title
    }

    # Clean intID without literal "NA"
    int_id <- paste(sprintf("%02d", indices), collapse = ".")

    # Question text (StaticText uses Text)
    q_text <- if (t == "StaticText") {
      node[["Text"]] %||% NA_character_
    } else {
      node[["QuestionText"]] %||% NA_character_
    }

    # Variable fields
    expr <- if (t == "Variable") node[["Expression"]] %||% NA_character_ else NA_character_
    var_type <- if (t == "Variable") node[["Type"]] %||% NA_integer_ else NA_integer_
    var_label <- node[["VariableLabel"]] %||% node[["Label"]] %||% NA_character_
    do_not_export <- if (t == "Variable") isTRUE(node[["DoNotExport"]]) else NA

    row_data <- list(
      Id = quest_id,
      LastEntryDate = last_entry,
      intID = int_id,
      indices = indices,
      type = t,
      PublicKey = node[["PublicKey"]] %||% NA_character_,
      VariableName = var_name,
      Title = title,
      QuestionText = q_text,
      QuestionScope = node[["QuestionScope"]] %||% NA_integer_,
      Featured = isTRUE(node[["Featured"]]),
      Instructions = node[["Instructions"]] %||% NA_character_,
      ConditionExpression = node[["ConditionExpression"]] %||% NA_character_,
      HideIfDisabled = isTRUE(node[["HideIfDisabled"]]),
      VariableLabel = var_label,
      StataExportCaption = node[["StataExportCaption"]] %||% NA_character_,
      IsRoster = is_roster,
      RosterSizeSource = node[["RosterSizeSource"]] %||% NA_integer_,
      RosterSizeQuestionId = node[["RosterSizeQuestionId"]] %||% NA_character_,
      SectionTitle = cur_section,
      RosterVariable = cur_roster_var,
      RosterTitle = cur_roster_title,
      Expression = expr,
      VariableType = var_type,
      DoNotExport = do_not_export,
      GeometryType = if (!is.null(node[["Properties"]][["GeometryType"]])) as.integer(node[["Properties"]][["GeometryType"]]) else NA_integer_
    )

    if (include_raw) {
      row_data$..JSON <- list(node)
    }

    q_list[[length(q_list) + 1]] <<- row_data

    # Validations
    vcs <- node[["ValidationConditions"]]
    if (length(vcs) > 0) {
      for (vc in vcs) {
        val_list[[length(val_list) + 1]] <<- list(
          intID = int_id,
          PublicKey = node[["PublicKey"]] %||% NA_character_,
          VariableName = var_name,
          QuestionText = q_text,
          SectionTitle = cur_section,
          RosterVariable = cur_roster_var,
          Expression = vc[["Expression"]] %||% NA_character_,
          Message = vc[["Message"]] %||% NA_character_,
          Severity = vc[["Severity"]] %||% 0L,
          SeverityLabel = if (identical(vc[["Severity"]], 1L) || identical(vc[["Severity"]], 1)) "Warning" else "Error"
        )
      }
    }

    # Answers
    answers <- node[["Answers"]]
    cat_id <- node[["CategoriesId"]]
    linked_q <- node[["LinkedToQuestionId"]]

    if (length(answers) > 0) {
      for (ans in answers) {
        ans_list[[length(ans_list) + 1]] <<- list(
          VariableName = var_name,
          PublicKey = node[["PublicKey"]] %||% NA_character_,
          AnswerValue = as.character(ans[["AnswerValue"]] %||% ""),
          AnswerText = ans[["AnswerText"]] %||% "",
          AnswerCode = ans[["AnswerCode"]] %||% NA_real_,
          isLinked = FALSE,
          CategoriesId = NA_character_,
          CategoryName = NA_character_
        )
      }
    } else if (!is.null(cat_id) && nchar(cat_id) > 0) {
      ans_list[[length(ans_list) + 1]] <<- list(
        VariableName = var_name,
        PublicKey = node[["PublicKey"]] %||% NA_character_,
        AnswerValue = NA_character_,
        AnswerText = NA_character_,
        AnswerCode = NA_real_,
        isLinked = FALSE,
        CategoriesId = cat_id,
        CategoryName = cat_map[[cat_id]] %||% NA_character_
      )
    } else if (!is.null(linked_q) && nchar(linked_q) > 0) {
      ans_list[[length(ans_list) + 1]] <<- list(
        VariableName = var_name,
        PublicKey = node[["PublicKey"]] %||% NA_character_,
        AnswerValue = NA_character_,
        AnswerText = NA_character_,
        AnswerCode = NA_real_,
        isLinked = TRUE,
        CategoriesId = NA_character_,
        CategoryName = NA_character_
      )
    }

    # Traverse children
    children <- node[["Children"]]
    if (length(children) > 0) {
      for (i in seq_along(children)) {
        traverse(children[[i]], c(indices, i), cur_section, cur_roster_var, cur_roster_title)
      }
    }
  }

  if (!is.null(doc$Children) && length(doc$Children) > 0) {
    for (i in seq_along(doc$Children)) {
      traverse(doc$Children[[i]], c(i), NA_character_, NA_character_, NA_character_)
    }
  }

  if (length(q_list) == 0) {
    return(list(
      q = data.table::data.table(),
      val = data.table::data.table(),
      v = data.table::data.table(),
      answers = data.table::data.table()
    ))
  }

  # Build L0, L1, ... coordinate columns
  idx_mat <- matrix(NA_integer_, nrow = length(q_list), ncol = max_depth)
  for (r in seq_along(q_list)) {
    idx <- q_list[[r]]$indices
    idx_mat[r, seq_along(idx)] <- idx
    q_list[[r]]$indices <- NULL
  }

  dt_q <- data.table::rbindlist(q_list, fill = TRUE)
  for (d in seq_len(max_depth)) {
    dt_q[, (paste0("L", d - 1)) := idx_mat[, d]]
  }

  dt_val <- if (length(val_list) > 0) data.table::rbindlist(val_list, fill = TRUE) else data.table::data.table()
  dt_ans <- if (length(ans_list) > 0) data.table::rbindlist(ans_list, fill = TRUE) else data.table::data.table()

  list(q = dt_q, val = dt_val, v = dt_val, answers = dt_ans)
}

# get all questions from questionnaire
.questionnaire_gpsquestion <- function(dt) {
  # Check if 'type' column exists
  if (!("type" %in% names(dt))) {
    stop("The 'type' column does not exist in the data table.")
  }

  # Identify rows where 'type' contains 'Gps' or 'AreaQuestion'
  rows_with_question <- dt[grepl("Gps", type) | grepl("AreaQuestion", type), ]
  # if none return nrow 0 dt
  if(nrow(rows_with_question) == 0) return(data.table::data.table(NULL))
  # create type1 with gps/map area/map point
  rows_with_question[, type1 := character(.N)]
  # gps
  rows_with_question[grepl("Gps", type), type1 := "GPS"]
  # map area (polygon, line, point)
  if ("GeometryType" %in% names(rows_with_question)) {
    rows_with_question[grepl("AreaQuestion", type) & GeometryType == 0L, type1 := "POLY"]
    rows_with_question[grepl("AreaQuestion", type) & GeometryType == 1L, type1 := "LINE"]
    rows_with_question[grepl("AreaQuestion", type) & GeometryType %in% c(2L, 3L), type1 := "POINT"]
  } else if ("..JSON" %in% names(rows_with_question)) {
    for(i in 1:nrow(rows_with_question)) {
      if(grepl("AreaQuestion", rows_with_question[i, type])) {
        geom <- rows_with_question$..JSON[[i]]$Properties$GeometryType
        if (!is.null(geom)) {
          if(geom == 0) rows_with_question[i, type1 := "POLY"]
          else if(geom == 1) rows_with_question[i, type1 := "LINE"]
          else if(geom %in% c(2, 3)) rows_with_question[i, type1 := "POINT"]
        }
      }
    }
  }

  return(rows_with_question[])
}

# categorical answer options
.questionnaire_answeroptions <- function(input_list, full_list) {
  # Initialize an empty data frame
  answers_df <- data.frame(AnswerValue = character(),
                           AnswerText = character(),
                           isLinked = logical(),
                           stringsAsFactors = FALSE)

  # Iterate through the outer list
  for (item in input_list) {
    # Check if 'Answers' is in the list
    if ("Answers" %in% names(item)) {
      # Extract the 'Answers' sublist

      if ("LinkedToQuestionId" %in% names(item)) {
        # if linked get max answers and creat response codes
        linkid<-item$LinkedToQuestionId
        tl<-full_list[PublicKey==linkid, .(..JSON)]
        tl<-tl$..JSON[[1]]
        # get the max count
        if ("MaxAnswerCount" %in% names(tl)) {
          maxCount<-tl$MaxAnswerCount
          varName<-tl$VariableName
          # generate levels and labels
          item$Answers<-mapply(
            function(x,y) list(AnswerValue = x, AnswerText = y),
            c(1:maxCount),
            sprintf("%s__%d", varName, 0:(maxCount-1)),
            SIMPLIFY = F, USE.NAMES = F
          )
          islink<-TRUE
        }

      } else {
        islink<-FALSE
      }

      answers <- item$Answers
      # Iterate through the 'Answers' sublist and add to the data frame
      for (answer in answers) {
        answers_df <- rbind(answers_df, data.frame(AnswerValue = answer$AnswerValue,
                                                   AnswerText = answer$AnswerText,
                                                   isLinked = islink,
                                                   stringsAsFactors = FALSE))
      }
    }
  }

  return(answers_df)
}

# remove HTML text
.questionnaire_remove_html_tags <- function(dt, column) {
  # Regular expression for HTML tags
  regex <- "<[^>]+>"

  # Applying gsub to remove HTML tags
  dt[, (column) := gsub(regex, "", get(column))]

  return(dt)
}

# convert multi/single select to factor
.export_convert_to_factor <- function(dt, labels_dt) {
  #dt<-copy(dt)
  # make values numeric if not
  if(!is.numeric(labels_dt$AnswerValue)) {
    labels_dt[, AnswerValue := as.numeric(AnswerValue)]
  }
  # on.exit(
  #   rm(dt),
  #   gc()
  # )
  # Unique base variable names
  base_vars <- unique(sub("__.*", "", names(dt)))
  # Use only base vars where factor is available
  base_vars <- base_vars[base_vars %in% labels_dt$VariableName]
  # Return dt if not base vars
  if (length(base_vars) == 0) {
    return(dt)
  }

  # Iterate over each base variable name
  for (base_var in base_vars) {
    # first check for single column (ie single select)
    if(base_var %in% names(dt)) {
      # Create factor
      label_rows <- labels_dt[VariableName == base_var]

      lev<-c(label_rows$AnswerValue)
      lab<-c(label_rows$AnswerText)

      dt[[base_var]]<-factor(dt[[base_var]],
                             levels = lev,
                             labels = lab)


    } else {

      # Find all columns related to this base variable
      related_cols <- grep(paste0("^", base_var, "__"), names(dt), value = TRUE)
      #dt[, c(base_var) := numeric(.N)]
      dt[[base_var]]<-numeric(nrow(dt))
      # Consolidate into a single variable
      for (col in related_cols) {
        fval<-as.integer(sub(paste0("^", base_var, "__"), "", col))
        dt[[base_var]]<-data.table::fifelse(dt[[col]] == 1, fval, dt[[base_var]])
      }

      # Drop the original long-form columns -->suppress the warning
      suppressWarnings(
        dt[, (related_cols) := NULL]
      )

      # Check if the base variable name is in the VariableName column of labels_dt
      if (base_var %in% labels_dt$VariableName) {
        # Extract labels_dt
        label_rows <- labels_dt[VariableName == base_var]

        lev<-c(label_rows$AnswerValue)
        lab<-c(label_rows$AnswerText)

        # Create factor
        dt[[base_var]]<-factor(dt[[base_var]],
                               levels = lev,
                               labels = lab)

      }
    }
  }

  return(dt)
}


