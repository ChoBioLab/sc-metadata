library(shiny)
library(DT)

# Define UI for app
ui <- fluidPage(
  titlePanel("Cho Lab SC Metadata"),
  mainPanel(
    DT::dataTableOutput("samples"),
    downloadButton("download_csv", "Download CSV")
  )
)

# Define server logic
server <- function(input, output) {
  # Define data for table
  sample_table <- read.csv("samples-out.csv")
  sample_table[sapply(sample_table, is.character)] <- lapply(
    sample_table[sapply(sample_table, is.character)],
    as.factor
  )

  # Create DT table with column filters
  output$samples <- DT::renderDataTable(
    DT::datatable(
      sample_table,
      filter = list(
        position = "top",
        clear = FALSE
      ),
      options = list(
        pageLength = 30,
        autoWidth = TRUE
      )
    )
  )

  # Download CSV file
  output$download_csv <- downloadHandler(
    filename = function() {
      paste("sc-metadata-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(sample_table, file, row.names = FALSE)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
