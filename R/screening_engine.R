library(DBI)

screen_reference <- function(reference_row,
                             protocol,
                             llm_response,
                             con,
                             model_name = "unknown") {

  answers_df <- parse_llm_json(llm_response)

  verdict <- apply_decision_rules(answers_df)

  for (i in seq_len(nrow(answers_df))) {
    dbExecute(
      con,
      paste0(
        "INSERT INTO screening_results ",
        "(reference_id, question_id, answer, confidence, evidence, model) ",
        "VALUES (?, ?, ?, ?, ?, ?)"
      ),
      params = list(
        reference_row$id,
        answers_df$question_id[i],
        as.character(answers_df$answer[i]),
        answers_df$confidence[i],
        answers_df$evidence[i],
        model_name
      )
    )
  }

  dbExecute(
    con,
    paste0(
      "UPDATE references ",
      "SET screening_status = 'screened', ",
      "decision = ? ",
      "WHERE id = ?"
    ),
    params = list(verdict, reference_row$id)
  )

  return(verdict)
}
