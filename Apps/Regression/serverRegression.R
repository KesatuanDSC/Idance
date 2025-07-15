
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
  
  varI1 <- input$IVariables[1]
  varI2 <- input$IVariables[2]
  varD <- input$DVariable
  
  # Buat plot ggplot dulu
  p <- ggplot(df) +
    geom_point(aes_string(x = varI1, y = varD), color = "blue", alpha = 0.6) +
    geom_smooth(aes_string(x = varI1, y = varD), method = "lm", se = FALSE, color = "blue") +
    geom_point(aes_string(x = varI2, y = varD), color = "orange", alpha = 0.6) +
    geom_smooth(aes_string(x = varI2, y = varD), method = "lm", se = FALSE, color = "orange") +
    labs(title = "Regression Plot",
         x = "Independent Variables",
         y = varD)
  
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
    writeLines(TheExplanation(),file)
  }
)
