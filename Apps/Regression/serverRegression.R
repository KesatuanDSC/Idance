dataRegression <- reactive({
  req(input$uploadRegression)
  
  ext <- tools::file_ext(input$uploadRegression$name)
  switch(ext,
         csv = vroom::vroom(input$uploadRegression$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadRegression$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadRegression$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

output$varSelectUI <- renderUI({
  req(dataRegression())
  df <- dataRegression()
  varNames <- names(df)
  tagList(
    fluidRow(
      column(4, selectInput("DVariable", "Dependent Variable", choices = varNames)),
      column(4, selectInput("IVariables", "Independent Variables", choices = varNames, multiple = TRUE)),
      column(4,              tags$div(style = "margin-top: 32px;",
                                      actionButton("runModel", "Run Model")
      )
      )
    )
  )
})

model <- eventReactive(input$runModel, {
  req(input$DVariable, input$IVariables)
  df <- dataRegression()
  formula <- as.formula(paste(input$DVariable, "~", paste(input$IVariables, collapse = "+")))
  print(df)
  lm(formula, data = df)
})

output$regressionPlot <- renderPlotly({
  req(model())
  df <- dataRegression()
  
  library(ggplot2)
  library(ggplot2)
  library(plotly)
  
  varsI <- input$IVariables  
  varD <- input$DVariable   
  
  p <- ggplot(df)
  
  colors <- c("blue", "orange", "green", "purple", "red", "brown", "pink", "cyan")
  
  for (i in seq_along(varsI)) {
    color <- colors[(i - 1) %% length(colors) + 1]  
    p <- p +
      geom_point(aes_string(x = varsI[i], y = varD), color = color, alpha = 0.6) +
      geom_smooth(aes_string(x = varsI[i], y = varD), method = "lm", se = FALSE, color = color)
  }
  
  p <- p + labs(
    title = "Regression Plot",
    x = "Independent Variables",
    y = varD
  )
  
  ggplotly(p)
  
  
  # Konversi ke plotly
  ggplotly(p) %>%
    layout(hoverlabel = list(
      bgcolor = "white",
      bordercolor = "black",
      font = list(color = "black")
    ))
})

output$regSummary <- renderPrint({
  req(model())
  summary(model())
})

TeksRegression <- reactive({
  req(model())
  za <- capture.output(summary(model()))
  zza <- paste0(za, collapse = "\n ")
  zza
})

TheExplanation <- reactive({
  req(TeksRegression())
  user_prompt <- TeksRegression()
  #  generate_completion(user_prompt, 'Regression')
  gemini_completion(user_prompt, 'Regression')
})

output$regExplanation <- renderText({
  req(TeksRegression())
  hasil <- TheExplanation()
  paste0("The Explanation of the Regression Model:\n", hasil)
})


# Convert model() into a text
output$regressionText <- renderText({
  req(model())
  za <- capture.output(summary(model()))
  zza <- paste0(za, collapse = "\n ")
  zza
})

output$downloadregExplanation <- downloadHandler(
  filename = function() {
    paste("Regression_Explanation_", Sys.Date(), ".txt", sep = "")
  },
  content = function(file) {
    writeLines(TheExplanation(), file)
  }
)
