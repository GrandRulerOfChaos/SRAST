library(jsonlite)

load_protocol <- function(protocol_path) {
  protocol <- fromJSON(protocol_path)

  validate_protocol(protocol)

  return(protocol)
}

validate_protocol <- function(protocol) {
  required_fields <- c("name", "version", "questions")

  missing_fields <- setdiff(required_fields, names(protocol))

  if (length(missing_fields) > 0) {
    stop(
      paste(
        "Protocol missing required fields:",
        paste(missing_fields, collapse = ", ")
      )
    )
  }

  question_fields <- c(
    "id",
    "text",
    "phase",
    "type"
  )

  for (i in seq_len(nrow(protocol$questions))) {
    question <- protocol$questions[i, ]

    missing_question_fields <- setdiff(
      question_fields,
      names(question)
    )

    if (length(missing_question_fields) > 0) {
      stop(
        paste(
          "Question missing required fields:",
          paste(missing_question_fields, collapse = ", ")
        )
      )
    }
  }

  TRUE
}

filter_questions_by_phase <- function(protocol, phase_name) {
  protocol$questions[
    protocol$questions$phase == phase_name,
  ]
}
