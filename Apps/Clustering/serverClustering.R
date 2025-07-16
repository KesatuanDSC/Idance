# --- Upload dan Persiapan Data ---
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
  as.data.frame(numeric_cols)
})

observe({
  updateSelectizeInput(session, 'ColumnClustering', choices = selectableFeatureClustering(), server = TRUE)
})

SelectedDataClustering <- reactive({
  req(input$ColumnClustering)
  df <- dataClustering()
  df <- df[, input$ColumnClustering, drop = FALSE]
  return(df)
})

SelectedIDClustering <- reactive({
  df <- dataClustering()
  rownames(df)
})

output$FeatureClusterize <- render_gt({
  req(SelectedDataClustering())
  head(SelectedDataClustering(), 10)
})

output$IDFeatureClusterize <- render_gt({
  req(SelectedIDClustering())
  head(data.frame(ID = SelectedIDClustering()), 10)
})

# --- Clustering dan Visualisasi ---
ClusterAssignment <- reactiveVal(NULL)
FilteredRowNames <- reactiveVal(NULL)

TheCluster <- eventReactive(input$Clusterize, {
  req(SelectedDataClustering())
  SelectedData <- SelectedDataClustering()
  
  complete_idx <- complete.cases(SelectedData)
  FilteredRowNames(rownames(SelectedData)[complete_idx])  # simpan rownames yang valid
  
  SelectedData <- SelectedData[complete_idx, , drop = FALSE]
  
  VarName <- colnames(SelectedData)
  xc <- lapply(VarName, function(x) paste(x, ":", format(SelectedData[[x]], big.mark = ".", decimal.mark = ","), "<br>"))
  S1 <- as.data.frame(do.call(cbind, xc))
  colnames(S1) <- VarName
  S1$Teks <- apply(S1, 1, paste, collapse = " ")
  
  ScaledData <- as.data.frame(scale(SelectedData))
  Data_K <- kmeans(ScaledData, centers = input$nCluster, nstart = 25)
  ClusterAssignment(Data_K$cluster)
  
  cluster <- as.factor(Data_K$cluster)
  pca <- stats::prcomp(ScaledData, scale = FALSE, center = FALSE)
  ind <- facto_summarize(pca, element = "ind", result = "coord", axes = c(1, 2))
  plot.data <- cbind.data.frame(ind, cluster = cluster, stringsAsFactors = TRUE)
  plot.data$Teks <- S1$Teks
  
  plot_ly(data = plot.data,
          x = ~Dim.1, y = ~Dim.2,
          color = ~cluster,
          colors = c("red", "blue", "green"),
          text = ~paste("<b>ID:</b>", FilteredRowNames(), "<br>", Teks),
          type = "scatter", mode = "markers")
})

output$ClusterPlot <- renderPlotly({
  TheCluster()
})

# --- Summary dan Penjelasan ---
output$SummaryCluster <- renderPrint({
  req(SelectedDataClustering())
  req(ClusterAssignment())
  req(FilteredRowNames())
  
  df <- SelectedDataClustering()
  df <- df[rownames(df) %in% FilteredRowNames(), , drop = FALSE]
  df$Cluster <- as.factor(ClusterAssignment())
  
  cat("Overall Data Summary:\n")
  print(summary(df[, !names(df) %in% "Cluster"]))
  
  cat("\n--- Summary per Cluster ---\n")
  for (cl in unique(df$Cluster)) {
    cat(paste0("\nCluster ", cl, ":\n"))
    print(summary(df[df$Cluster == cl, !names(df) %in% "Cluster"]))
  }
})

ClusterSummaryText <- reactive({
  req(SelectedDataClustering())
  req(ClusterAssignment())
  req(FilteredRowNames())
  
  data <- SelectedDataClustering()
  data <- data[rownames(data) %in% FilteredRowNames(), , drop = FALSE]
  data$Cluster <- as.factor(ClusterAssignment())
  
  teks_summary <- capture.output({
    cat("Overall Data Summary:\n")
    print(summary(data[, !names(data) %in% "Cluster"]))
    for (cl in unique(data$Cluster)) {
      cat(paste0("\nCluster ", cl, ":\n"))
      print(summary(data[data$Cluster == cl, !names(data) %in% "Cluster"]))
    }
  })
  paste0(teks_summary, collapse = "\n")
})

TheClusteringExplanation <- reactive({
  req(ClusterSummaryText())
  user_prompt <- ClusterSummaryText()
  gemini_completion(user_prompt, 'Clustering')
})

output$clusterExplanation <- renderText({
  req(TheClusteringExplanation())
  hasil <- TheClusteringExplanation()
  paste0("Penjelasan hasil Clustering:\n", hasil)
})

output$downloadClusterExplanation <- downloadHandler(
  filename = function() {
    paste("Clustering_Explanation_", Sys.Date(), ".txt", sep = "")
  },
  content = function(file) {
    writeLines(TheClusteringExplanation(), file)
  }
)

