library(DBI)
library(RSQLite)

initialize_database <- function(db_path = "srast.sqlite") {
  con <- dbConnect(SQLite(), db_path)

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS references (
      id INTEGER PRIMARY KEY,
      title TEXT,
      abstract TEXT,
      doi TEXT,
      authors TEXT,
      year TEXT,
      journal TEXT,
      source_file TEXT,
      screening_status TEXT,
      decision TEXT,
      confidence REAL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS protocols (
      id INTEGER PRIMARY KEY,
      name TEXT,
      version TEXT,
      sha256 TEXT,
      json TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS screening_results (
      id INTEGER PRIMARY KEY,
      reference_id INTEGER,
      question_id TEXT,
      answer TEXT,
      confidence REAL,
      evidence TEXT,
      model TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")

  dbExecute(con, "
    CREATE TABLE IF NOT EXISTS overrides (
      id INTEGER PRIMARY KEY,
      reference_id INTEGER,
      human_decision TEXT,
      reviewer TEXT,
      reason TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  ")

  return(con)
}
