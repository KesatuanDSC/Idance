library(MUS)


dataPopulation <- reactive({
  req(input$uploadMUS)
  
  ext <- tools::file_ext(input$uploadMUS$name)
  switch(ext,
         csv = vroom::vroom(input$uploadMUS$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadMUS$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadMUS$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

observeEvent(input$update, {
  updateTextInput(session, "text", value = "Updated text")
})


output$KontenMUS <- render_gt({
  req(dataPopulation())
  head(dataPopulation(), 10)
})

output$varSelectColumnMUS <- renderUI({
  req(dataPopulation())
  df <- dataPopulation()
  varNames <- names(df)
  tagList(
    selectInput("SelectColumnMUS", "Select a Monetary Column", choices = varNames)
  )
})

output$varSelectColumnStrata <- renderUI({
  req(dataPopulation())
  df <- dataPopulation()
  varNames <- names(df)
  tagList(
    selectInput("SelectColumnStrata", "Select a Monetary Column", choices = varNames),
    h4(paste("Number of Strata: ", as.integer(1 + 3.3 * log(nrow(df)))))
  )
})

SumAllPopulation <- reactive({
  req(dataPopulation(), input$SelectColumnMUS)
  df <- dataPopulation()
  colName <- input$SelectColumnMUS
  sum(df[[colName]])
})


Planning <- eventReactive(input$runMUS, {
  req(input$SelectColumnMUS, input$sliderConf, input$sliderTE, input$sliderEE, input$MinSize, dataPopulation())
  df <- dataPopulation()
  totalPop <- SumAllPopulation()
  MUS.planning(df, 
               col.name.book.values = input$SelectColumnMUS, 
               confidence.level = input$sliderConf/100, 
               tolerable.error = totalPop * (input$sliderTE/100), 
               expected.error = (totalPop * (input$sliderTE/100))* (input$sliderEE/100), 
               n.min = input$MinSize, 
               errors.as.pct = FALSE, conservative = TRUE, combined = TRUE)
})

ExtractSample <- reactive({
  req(Planning())
  dx <- Planning()
  ExtractedSample <- MUS.extraction(Planning())
  ExtractedSample$sample
})

output$musTable <- renderDT(server = FALSE, {
  req(ExtractSample())
  df <- ExtractSample()
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
  )
})

ExtractRandomSampling <- eventReactive(input$runRandom, {
  req(input$MinSizeRandom, dataPopulation())
  df <- dataPopulation()
  rand_df <- df[sample(nrow(df), size=input$MinSizeRandom), ]
})

output$randomTable <- renderDT(server = FALSE, {
  req(ExtractRandomSampling())
  df <- ExtractRandomSampling()
  DT::datatable(df,
                extensions = 'Buttons',
                options = list(
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'csv', filename = paste0("Random_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'excel', filename = paste0("Random_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'pdf', filename = paste0("Random_", format(Sys.time(), "%Y%m%d_%H%M%S")))),
                  text = 'Download'
                )
  )
})

StratedData <- eventReactive(input$runStrata,{
  req(dataPopulation(), input$SelectColumnStrata, input$sliderStratSize)
  df <- dataPopulation()
  n <- nrow(df)
  k <- 1+3.3*log(n)
  minval <- min(df[,input$SelectColumnStrata])
  maxval <- max(df[,input$SelectColumnStrata])
  rangevalue <- nrow(df) - 1
  nclass <- as.integer(k)
  classinterval <- rangevalue/nclass
  Sorted <- df[order(df[,input$SelectColumnStrata], decreasing = TRUE),]
  Sorted$Rank <- 1:nrow(Sorted)
  rownames(Sorted) <- Sorted$Rank
  freq <- cut(Sorted$Rank, 
              breaks = seq(1, nrow(Sorted), by = classinterval),
              labels = c(1:nclass), 
              right = FALSE)
  freq <- as.data.frame(freq)
  SampleSize <- input$sliderStratSize/100
  Sortedx <- merge(Sorted, freq, by = "row.names")
  strata <- split(Sortedx, Sortedx$freq)
  strata <- lapply(strata, function(x) x[sample(1:nrow(x), SampleSize*nrow(x)),])
  strata <- do.call(rbind, strata)
  strata
})

output$StrataTable <- renderDT(server = FALSE, {
  req(StratedData())
  df <- StratedData()
  DT::datatable(df,
                extensions = 'Buttons',
                options = list(
                  dom = 'Bfrtip',
                  buttons = list(
                    list(extend = 'csv', filename = paste0("Stratified_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'excel', filename = paste0("Stratified_", format(Sys.time(), "%Y%m%d_%H%M%S"))),
                    list(extend = 'pdf', filename = paste0("Stratified_", format(Sys.time(), "%Y%m%d_%H%M%S")))),
                  text = 'Download'
                )
  )
})

