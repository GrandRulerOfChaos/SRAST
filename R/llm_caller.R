library(jsonlite)

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
  parsed <- fromJSON(response_text)

  if (!"answers" %in% names(parsed)) {
    stop("LLM response missing answers field")
  }

  return(parsed$answers)
}
