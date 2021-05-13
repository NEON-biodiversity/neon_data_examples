library(shiny)
library(neonDivData)

ui <- fluidPage(
    selectInput("dataset", label = "Dataset", choices = ls("package:neonDivData")),
    htmlOutput("xselector"),    htmlOutput("yselector"),

    verbatimTextOutput("summary_of_dataset"),
    # tableOutput("table_of_dataset")
)

server <- function(input,output, session){

    dataset <- reactive({
        get(input$dataset, "package:neonDivData")
    })

    output$xselector<- renderUI({
        selectInput(
            inputId = "x",
            label = "X:",
            choices = as.character(names(get(input$dataset)))
        )

    })

    output$yselector<- renderUI({
        selectInput(
            inputId = "y",
            label = "Y:",
            choices = as.character(names(get(input$dataset)))
        )

    })


    output$summary_of_dataset <- renderPrint({
        summary(dataset())
    })

    # output$table_of_dataset <- renderTable( {dataset()} )
}
shinyApp(ui, server)

