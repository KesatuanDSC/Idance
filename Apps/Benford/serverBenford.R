dataBenford <- reactive({
  req(input$uploadBenford)
  ext <- tools::file_ext(input$uploadBenford$name)
  print(ext)
  switch(ext,
         csv = vroom::vroom(input$uploadBenford$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadBenford$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadBenford$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

output$varSelectUIBenford <- renderUI({
  req(dataBenford())
  df <- dataBenford()
  varNames <- names(df)
  tagList(
    fluidRow(
      column(8, selectInput("BVariable", "Numeric Column", choices = varNames, multiple = FALSE)),
      column(4, numericInput("NumberofDigit", "Number of Digit to Test", value = 2))
    ),
    actionButton("runBenford", "Run Benford")
  )
})

resultBA <- eventReactive(input$runBenford, {
  req(input$BVariable, input$NumberofDigit)
  myDataSet <- dataBenford()
  print(input$BVariable)
  myDataSet[, input$BVariable] <- as.numeric(myDataSet[[input$BVariable]])
  rem = ifelse(myDataSet[,input$BVariable]>=10,1,NA)
  myDataSet$fd = as.numeric(str_sub(myDataSet[[input$BVariable]],1,1))
  myDataSet$sd = as.numeric(str_sub(myDataSet[[input$BVariable]],2,2))*rem
  myDataSet$f2d = as.numeric(str_sub(myDataSet[[input$BVariable]],1,2))*rem
  
  myDataSet <- na.omit(myDataSet)
  output = list()
  print(head(myDataSet))

  d1 = myDataSet%>% group_by(fd) %>% count()
  d12 = (myDataSet%>% group_by(f2d) %>% count())[1:90,]

  print(d1)
  n1 = nrow(myDataSet)
  n2 = n12 = nrow(filter(myDataSet,!is.na(sd)))

  df1 = data.frame(1:9,d1[,2]/n1,d1[,2],n1) # Get Proportion, Count, and Total Count
  df12 = data.frame(10:99,d12[,2]/n12,d12[,2],n12) # Get Proportion, Count, and Total Count
  print(df1)

  colnames(df1) = colnames(df12) = c("digit", "prop", "count","n")
  output = list(first1 = df1, first2 = df12)
  return(output)
})

BendfordResult <- eventReactive(input$runBenford, {
  req(input$BVariable, input$NumberofDigit)
  dataSet <- dataBenford()
  data <- dataSet[[input$BVariable]]
  data = as.numeric(data)
  bfordResult <- benford(data, input$NumberofDigit, discrete=TRUE, sign="both") #generates benford object
  return(bfordResult)
})

output$PlotBenford <- renderPlot({
  req(BendfordResult)
  bfordResult <- BendfordResult()
  plot(bfordResult) #plots
})

output$BenfordResult <- renderDT({
  req(BendfordResult)
  dataSet <- dataBenford()
  bfordResult <- BendfordResult()
  ds0 <- ZAndSummationTest(bfordResult)
  ds <- ComputeSummation(ds0)
  summationTest <- subset(ds, summation_test > 0.01375)
  summationTest <- summationTest[order(-summationTest$summation_test),]
  
  #List top 10 divergence in Summation test)
  suspectDigits <- head(summationTest %>% select(digits,observed_frequency,summation, summation_test),10)
  #Given top 10 summation test divergences, select municipalities in which test variable leading digits begin with.
  suspectRecords <- c()
  for (row in 1:nrow(suspectDigits)){
    p1 <- paste("^",suspectDigits[row,"digits"],sep = "")
    suspectRecords <- rbind(suspectRecords, subset(dataSet[order(-dataSet[[input$BVariable]]),], grepl(p1, dataSet[[input$BVariable]])))
  }
  suspectRecords$X <- NULL
  
  df <- suspectRecords
  print(df)
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
