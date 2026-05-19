library(shiny)
library(DT)

source("R/db.R")
source("R/import_engine.R")
source("R/protocol_engine.R")
source("R/decision_engine.R")
source("R/llm_caller.R")
source("R/screening_engine.R")

con <- initialize_database()

ui <- fluidPage(
  titlePanel("SRAST - Systematic Review AI Screening Tool"),

  sidebarLayout(
    sidebarPanel(
      fileInput(
        "csv_file",
        "Import CSV References"
      ),

      actionButton(
        "load_protocol",
        "Load Example Protocol"
      ),

      actionButton(
        "refresh_refs",
        "Refresh References"
      )
    ),

    mainPanel(
      h3("Unscreened References"),

      DTOutput("references_table"),

      h3("System Status"),

      verbatimTextOutput("status_output")
    )
  )
)

server <- function(input, output, session) {

  protocol_data <- reactiveVal(NULL)

  observeEvent(input$load_protocol, {
    protocol <- load_protocol(
      "protocols/example_protocol.json"
    )

    protocol_data(protocol)
  })

  observeEvent(input$csv_file, {
    req(input$csv_file)

    imported_count <- import_csv_references(
      input$csv_file$datapath,
      con
    )

    showNotification(
      paste(imported_count, "references imported")
    )
  })

  references_data <- reactive({
    input$refresh_refs

    get_unscreened_references(con)
  })

  output$references_table <- renderDT({
    datatable(references_data())
  })

  output$status_output <- renderPrint({
    list(
      protocol_loaded = !is.null(protocol_data()),
      unscreened_references = nrow(references_data())
    )
  })
}

shinyApp(ui, server)
