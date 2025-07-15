
dataFuzzyDup <- reactive({
  req(input$uploadFuzzyDup)
  ext <- tools::file_ext(input$uploadFuzzyDup$name)
  print(ext)
  switch(ext,
         csv = vroom::vroom(input$uploadFuzzyDup$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadFuzzyDup$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadFuzzyDup$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

output$varSelectUIFD <- renderUI({
  req(dataFuzzyDup())
  df <- dataFuzzyDup()
  varNames <- names(df)
  tagList(
    fluidRow(
      column(8,
             selectInput("FDVariables", "Duplicate Key ID", choices = varNames, multiple = FALSE)
      ),
      column(4,
             tags$div(style = "margin-top: 32px;",
                      actionButton("runFuzzy", "Run Fuzzy")
             )
      )
    )
  )
})

resultFD <- eventReactive(input$runFuzzy, {
  req(input$FDVariables)
  df <- dataFuzzyDup()
  data <- df[, c(input$FDVariables)]
  df$Cleansing <- df$Cleansing <- paste(trimws(df[,input$FDVariables]))
  df$Cleansing <- gsub("[^[:alnum:] ]",'',df$Cleansing)
  NomorCluster <- 1
  hasil.akhir <- NULL
  Populasi <- length(df[,input$FDVariables])
  while(length(df[,input$FDVariables])>0){
    RujukanPembanding <- df$Cleansing[1]
    JarakTeks <- stringdist(gsub(" ","",RujukanPembanding), 
                            gsub(" ","",df$Cleansing),
                            method = "cosine")
    FilterJarak <- (JarakTeks <= 0.0125)
    var.temp <- df[FilterJarak,]
    var.temp$Cluster <- NomorCluster
    var.temp$Skor <- JarakTeks[FilterJarak]
    nCluster <- nrow(var.temp)
    if(nCluster > 1){
      hasil.akhir <- rbind(hasil.akhir, var.temp)
      NomorCluster <- NomorCluster + 1
    }
    df <- df[!(FilterJarak),]
  }
  return(hasil.akhir)
})

output$tableFuzzyDup <- renderDT(server = FALSE, {
  req(resultFD())
  warna <- c('red','blue','green','black','brown')
  df <- resultFD()
  df$bg <- df$Cluster %% 5
  DT::datatable(df,
                extensions = 'Buttons',
                options = list(
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'csv', filename = paste0("MUS_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'excel', filename = paste0("MUS_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'pdf', filename = paste0("MUS_", format(Sys.time(), "%Y%m%d_%H%M%S")))),
                  text = 'Download'
                )
  ) %>%
    DT::formatStyle("bg", target = "row", backgroundColor = styleEqual(c(0:4),warna))
})