library(shiny)
library(DT)

# Define UI for app
ui <- fluidPage(
  titlePanel("DT Table with Column Filters and Download Button"),
  mainPanel(
    DT::dataTableOutput("mytable"),
    downloadButton("download_csv", "Download CSV")
  )
)

# Define server logic
server <- function(input, output) {
  
  # Define data for table
  mydata <- read.csv('output.csv')
  
  # Create DT table with column filters
  output$mytable <- DT::renderDataTable(
    DT::datatable(mydata, 
                  filter = 'top',
                  options = list(pageLength = 30,
                                 autoWidth = TRUE, 
                                 columnDefs = list(list(targets = "_all", className = "dt-center")),
                                 dom = 'Bfrtip', 
                                 buttons = c('copy', 'csv', 'excel', 'pdf', 'print')))
  )
  
  # Download CSV file
  output$download_csv <- downloadHandler(
    filename = function() {
      paste("mydata", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(mydata, file, row.names = FALSE)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)

