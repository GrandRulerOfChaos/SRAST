library(readr)
library(DBI)

import_csv_references <- function(csv_path, con) {
  refs <- read_csv(csv_path, show_col_types = FALSE)

  required_columns <- c("title", "abstract")

  missing_columns <- setdiff(required_columns, names(refs))

  if (length(missing_columns) > 0) {
    stop(
      paste(
        "Missing required columns:",
        paste(missing_columns, collapse = ", ")
      )
    )
  }

  refs$screening_status <- "unscreened"
  refs$decision <- NA
  refs$confidence <- NA

  dbWriteTable(
    con,
    "references",
    refs,
    append = TRUE,
    row.names = FALSE
  )

  return(nrow(refs))
}

get_unscreened_references <- function(con, limit = 100) {
  dbGetQuery(
    con,
    paste0(
      "SELECT * FROM references ",
      "WHERE screening_status = 'unscreened' ",
      "LIMIT ", limit
    )
  )
}
