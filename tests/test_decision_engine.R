source("R/decision_engine.R")

results_include <- data.frame(
  answer = c(TRUE, TRUE),
  confidence = c(0.95, 0.92)
)

results_exclude <- data.frame(
  answer = c(TRUE, FALSE),
  confidence = c(0.95, 0.92)
)

results_doubt <- data.frame(
  answer = c(TRUE, TRUE),
  confidence = c(0.95, 0.50)
)

stopifnot(apply_decision_rules(results_include) == "include")
stopifnot(apply_decision_rules(results_exclude) == "exclude")
stopifnot(apply_decision_rules(results_doubt) == "doubt")

cat("All decision engine tests passed.\n")
