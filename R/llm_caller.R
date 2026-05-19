library(jsonlite)

strip_json_fences <- function(text) {
  if (is.null(text) || length(text) == 0 || is.na(text)) {
    stop("LLM response is empty")
  }

  cleaned <- trimws(text)
  cleaned <- sub("^```(?:json)?\\s*", "", cleaned, perl = TRUE)
  cleaned <- sub("\\s*```$", "", cleaned, perl = TRUE)

  cleaned
}

extract_json_payload <- function(response_text) {
  cleaned <- strip_json_fences(response_text)

  if (startsWith(cleaned, "{") && endsWith(cleaned, "}")) {
    return(cleaned)
  }

  first_open <- regexpr("\\{", cleaned, perl = TRUE)[1]
  last_close <- tail(gregexpr("\\}", cleaned, perl = TRUE)[[1]], 1)

  if (first_open > 0 && length(last_close) == 1 && last_close > first_open) {
    return(substr(cleaned, first_open, last_close))
  }

  stop("Unable to locate JSON payload in LLM response")
}

validate_answers_frame <- function(answers) {
  required_columns <- c("question_id", "answer", "confidence", "evidence")
  missing_columns <- setdiff(required_columns, names(answers))

  if (length(missing_columns) > 0) {
    stop(
      paste(
        "LLM answers missing required fields:",
        paste(missing_columns, collapse = ", ")
      )
    )
  }

  answers
}

build_screening_prompt <- function(reference_row, protocol_questions) {
  question_block <- paste0(
    seq_len(nrow(protocol_questions)),
    ". ",
    protocol_questions$text,
    collapse = "\n"
  )

  prompt <- paste(
    "You are assisting with systematic review screening.",
    "Answer all questions in strict JSON format.",
    "\n\nTitle:\n",
    reference_row$title,
    "\n\nAbstract:\n",
    reference_row$abstract,
    "\n\nQuestions:\n",
    question_block
  )

  return(prompt)
}

parse_llm_json <- function(response_text) {
  json_text <- extract_json_payload(response_text)
  parsed <- fromJSON(json_text, simplifyVector = TRUE)

  if (!"answers" %in% names(parsed)) {
    stop("LLM response missing answers field")
  }

  answers <- parsed$answers
  answers <- validate_answers_frame(answers)

  if (!is.data.frame(answers)) {
    answers <- as.data.frame(answers, stringsAsFactors = FALSE)
  }

  answers
}
