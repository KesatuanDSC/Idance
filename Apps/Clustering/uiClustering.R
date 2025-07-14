iClustering_tab <- tabItem(
  tabName = "iClustering",
  tabBox(
    title = "Interactive Clustering",
    elevation = 2,
    id = "Box",
    width = 12,
    collapsible = FALSE, 
    closable = FALSE,
    type = "tabs",
    status = "warning",
    solidHeader = TRUE,
    selected = "Preparation",
    # Preparation Tab ----
    tabPanel(
      "Preparation",
      box(
        title = "Preparation",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        fileInput("uploadCluster", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
        tableOutput("filesCluster"),
        gt_output("headClustering")
      )
    ),
    # Feature Selection Tab ----
    tabPanel(
      "Feature Selection",
      box(
        "Feature Selection",
        title = "Features Selection",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        selectizeInput(
          'ColumnClustering', 
          label = "Choose Features [ >=2 ]", 
          choices = NULL, 
          multiple = TRUE,
          options = list(
            placeholder = 'Select Features [ >=2 ]'
          )
        # selectizeInput(
        #   'IDColumnClustering', 
        #   label = "Choose Identity Feature[s] [ >=2 ]", 
        #   choices = NULL, 
        #   multiple = TRUE,
        #   options = list(
        #   placeholder = 'Select Identity Features [ >=2 ]'
        #   )
        ),
        numericInput(
          inputId = "nCluster",
          label = "Number of Clusters",
          value = 3,
          min = 2,
          max = 10,
          step = 1
        ),
        actionButton(inputId = "Clusterize", label = "Show Cluster"),
        plotlyOutput("ClusterPlot")
      )
    ),
    # Summary Data Tab ----
    tabPanel(
      "Data Summary",
      box(
        "Data Summary",
        title = "Data Summary",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        verbatimTextOutput("SummaryCluster")
      )
    )
  )
)
