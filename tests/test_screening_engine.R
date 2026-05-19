source("R/decision_engine.R")
source("R/llm_caller.R")
source("R/screening_engine.R")

mock_response <- '{
  "answers": [
    {
      "question_id": "human_population",
      "answer": true,
      "confidence": 0.95,
      "evidence": "Adult patients were enrolled"
    },
    {
      "question_id": "randomized_trial",
      "answer": true,
      "confidence": 0.91,
      "evidence": "Participants were randomized"
    }
  ]
}'

parsed <- parse_llm_json(mock_response)

stopifnot(nrow(parsed) == 2)
stopifnot(parsed$question_id[1] == "human_population")
stopifnot(parsed$answer[1] == TRUE)

verdict <- apply_decision_rules(parsed)

stopifnot(verdict == "include")

cat("Screening engine tests passed.\n")
