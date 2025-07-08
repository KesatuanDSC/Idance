
output$filesCluster <- renderTable(input$uploadCluster)

dataClustering <- reactive({
  req(input$uploadCluster)
  
  ext <- tools::file_ext(input$uploadCluster$name)
  switch(ext,
         csv = vroom::vroom(input$uploadCluster$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadCluster$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadCluster$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

selectableFeatureClustering <- reactive({
  req(dataClustering())
  colnames(dataClustering())[sapply(dataClustering(), is.numeric)]
})

selectableIdentityFeatureClustering <- reactive({
  req(dataClustering())
  colnames(dataClustering())
})

output$headClustering <- render_gt({
  head(dataClustering(), 10)
})

output$ColumnClustering <- render_gt({
  dx <- dataClustering()
  numeric_cols <- colnames(dx)[sapply(dx, is.numeric)]
  result <- as.data.frame(numeric_cols)
})
observe({
  updateSelectizeInput(session, 'ColumnClustering', choices = selectableFeatureClustering(), server = TRUE)
  updateSelectizeInput(session, 'IDColumnClustering', choices = selectableIdentityFeatureClustering(), server = TRUE)
})

SelectedDataClustering <- eventReactive(input$Clusterize, {
  req(input$ColumnClustering)
  req(dataClustering())
  if(length(input$ColumnClustering) <= 1) {
    return(NULL)
  } else {
    selected_cols <- input$ColumnClustering
    selectedData <- dataClustering()[, selected_cols]
  }
})

SelectedIDClustering <- eventReactive(input$Clusterize, {
  req(input$IDColumnClustering)
  req(dataClustering())
  if(length(input$IDColumnClustering) == 1) {
    selectedData <- dataClustering()[, input$IDColumnClustering]
    print(selectedData)
  } else {
    selected_cols <- input$IDColumnClustering
    selectedData <- dataClustering()[, selected_cols]
  }
})


output$FeatureClusterize <- render_gt({
  print("Cek01")
  req(SelectedDataClustering())
  head(SelectedDataClustering(), 10)
})

output$IDFeatureClusterize <- render_gt({
  print("Cek02")
  req(SelectedIDClustering())
  head(SelectedIDClustering(), 10)
})


TheCluster <- reactive({
  req(SelectedDataClustering())
  SelectedData <- SelectedDataClustering()
  SelectedData <- SelectedData[complete.cases(SelectedData),] %>%
    as.data.frame()
  #Preparing teks untuk muncul saat hover
  VarName <- colnames(SelectedData)
  xc <- lapply(VarName, function(x) paste(x,":",format(SelectedData[[x]], big.mark='.',decimal.mark=',' ),"<br>"))
  S1 <- as.data.frame(do.call(cbind, xc))
  colnames(S1) <- VarName
  nr <- nrow(S1)
  for (i in 1:nr) {
    S1[i, "Teks"] <- paste(unlist(S1[i, ]), collapse = " ")
  }
  # End of preparing teks

  ScaledData <- as.data.frame(scale(SelectedData))
  Data_K3 <- kmeans(ScaledData, centers = 3, nstart = 25)
  cluster <- as.factor(Data_K3$cluster)
  axes <- c(1,2)
  pca <- stats::prcomp(ScaledData, scale = FALSE, center = FALSE)
  ind <- facto_summarize(pca, element = "ind", result = "coord", axes = axes)
  plot.data <- cbind.data.frame(ind, cluster = cluster, stringsAsFactors = TRUE)
  plot.data$Teks <- S1$Teks
  p3 <- plot_ly(data = plot.data,
                x = ~Dim.1, y = ~Dim.2,
                color = ~cluster,
                colors = c("red", "blue", "green"),
                text = ~paste("<b> ID:", name, "<br>",
                              Teks),
                type = "scatter", mode = "markers")
  #  p3 <- fviz_cluster(BUMN_K3, palette = "Dark2",repel = TRUE,  data = ScaledData) + ggtitle(" K = 3")
  #  ThePlot <- grid.arrange(p1, p2, p3, p4, nrow = 2)
  return(p3)
})

output$ClusterPlot <- renderPlotly({
  TheCluster()
})

output$SummaryCluster <- renderPrint({
  req(SelectedDataClustering())
  summary(SelectedDataClustering())
})