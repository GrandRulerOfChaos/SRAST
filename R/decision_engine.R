apply_decision_rules <- function(results_df, confidence_threshold = 0.70) {
  exclusion_triggered <- any(results_df$answer == FALSE)

  low_confidence <- any(results_df$confidence < confidence_threshold)

  if (exclusion_triggered) {
    return("exclude")
  }

  if (low_confidence) {
    return("doubt")
  }

  return("include")
}
