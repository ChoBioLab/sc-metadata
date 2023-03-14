library(shiny)
library(DT)

# Define UI for app
ui <- fluidPage(
  titlePanel("Cho Lab SC Metadata"),
  mainPanel(
    tabsetPanel(
      type = "tabs",
      br(),
      tabPanel("samples", DT::dataTableOutput("sample_table")),
      tabPanel("fixed", DT::dataTableOutput("fixed_table"))
    )
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

  fixed_table <- read.csv("fixed-out.csv")
  fixed_table[sapply(fixed_table, is.character)] <- lapply(
    fixed_table[sapply(fixed_table, is.character)],
    as.factor
  )

  # Create DT table with column filters
  output$sample_table <- DT::renderDataTable(
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

  output$fixed_table <- DT::renderDataTable(
    DT::datatable(
      fixed_table,
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
      paste(
        "sc-metadata",
        Sys.Date(),
        ".csv",
        sep = ""
      )
    },
    content = function(file) {
      write.csv(
        a,
        file,
        row.names = FALSE
      )
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
