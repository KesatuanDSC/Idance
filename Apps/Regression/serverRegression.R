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
      column(5, selectInput("DVariable", "Dependent Variable", choices = varNames)),
      column(5, selectInput("IVariables", "Independent Variables", choices = varNames, multiple = TRUE)),
      column(2, actionButton("runModel", "Run Model"))
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

output$regressionPlot <- renderPlot({
  req(model())
  df <- dataRegression()
    ggplot(df, aes_string(x = input$IVariables[1], y = input$DVariable)) +
      geom_point() +
      geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
      labs(title = "Regression Plot", x = input$IVariables[1], y = input$DVariable)
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