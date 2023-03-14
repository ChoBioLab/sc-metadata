library(shiny)
library(DT)

# Define UI for app
ui <- fluidPage(
  titlePanel("Cho Lab SC Metadata"),
  mainPanel(
    DT::dataTableOutput("mytable"),
    downloadButton("download_csv", "Download CSV")
  )
)

# Define server logic
server <- function(input, output) {
  # Define data for table
  a <- read.csv("output.csv")
  a[sapply(a, is.character)] <- lapply(
    a[sapply(a, is.character)],
    as.factor
  )

  # Create DT table with column filters
  output$mytable <- DT::renderDataTable(
    DT::datatable(
      a,
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
      paste("sc-metadata", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(a, file, row.names = FALSE)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
