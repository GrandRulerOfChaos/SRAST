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
      "decision = ?, ",
      "confidence = ? ",
      "WHERE id = ?"
    ),
    params = list(
      verdict,
      min(answers_df$confidence),
      reference_row$id
    )
  )

  return(list(
    reference_id = reference_row$id,
    verdict = verdict,
    confidence = min(answers_df$confidence),
    answers = answers_df
  ))
}

screen_reference_batch <- function(references_df,
                                   protocol,
                                   llm_callback,
                                   con,
                                   model_name = "unknown") {

  batch_results <- vector("list", nrow(references_df))

  for (i in seq_len(nrow(references_df))) {
    reference_row <- references_df[i, ]

    llm_response <- llm_callback(reference_row, protocol)

    batch_results[[i]] <- screen_reference(
      reference_row = reference_row,
      protocol = protocol,
      llm_response = llm_response,
      con = con,
      model_name = model_name
    )
  }

  batch_results
}
