
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
  
  validate(
    need(input$DVariable %in% names(df), "⚠️ Error: Variabel dependen tidak ditemukan di data."),
    need(all(input$IVariables %in% names(df)), "⚠️ Error: Satu atau lebih variabel independen tidak ditemukan di data."),
    need(is.numeric(df[[input$DVariable]]), "⚠️ Error: Variabel dependen harus bertipe numerik."),
    need(all(sapply(df[input$IVariables], is.numeric)), "⚠️ Error: Semua variabel independen harus bertipe numerik.")
  )
  
  formula <- as.formula(paste(input$DVariable, "~", paste(input$IVariables, collapse = "+")))
  print(df)
  lm(formula, data = df)
})

output$regressionPlot <- renderPlotly({
  df <- dataRegression()
  varD <- input$DVariable
  ivars <- input$IVariables
  
  validate(
    need(length(ivars) >= 1, "⚠️ Error: Pilih minimal satu variabel independen."),
    need(varD %in% names(df), "⚠️ Error: Variabel dependen tidak ditemukan di data."),
    need(all(ivars %in% names(df)), "⚠️ Error: Satu atau lebih variabel independen tidak ditemukan di data."),
    need(is.numeric(df[[varD]]), "⚠️ Error: Variabel dependen harus bertipe numerik."),
    need(all(sapply(df[ivars], is.numeric)), "⚠️ Error: Semua variabel independen harus bertipe numerik.")
  )
  
  req(model())
  
  # Buat data dalam format long
  df_list <- lapply(ivars, function(varI) {
    df %>%
      dplyr::select(!!sym(varI), !!sym(varD)) %>%
      dplyr::rename(IndepVar = !!sym(varI)) %>%
      dplyr::mutate(Variable = varI)
  })
  
  df_long <- dplyr::bind_rows(df_list)
  
  # Plot
  p <- ggplot(df_long, aes(x = IndepVar, y = !!sym(varD), color = Variable)) +
    geom_point(alpha = 0.6, size = 2) +
    geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
    labs(
      title = "Regression Plot",
      x = "Independent Variable",
      y = varD,
      color = "Variabel"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
      axis.title = element_text(size = 14),
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 11)
    ) +
    scale_color_manual(values = setNames(
      RColorBrewer::brewer.pal(n = length(ivars), name = "Set2"),
      ivars
    ))
  
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
  # gemini_completion
  generate_completion(user_prompt, 'Regression')
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

