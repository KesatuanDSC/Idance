iNetwork_tab <- tabItem(
  tabName = "iNetwork",
  tabBox(
    title = "Network Graph",
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
        fileInput("uploadNetwork", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
        tableOutput("filesNetwork"),
        gt_output("headNetwork")
      )
    ),
    ## Configuration Tab ----
    tabPanel(
      "Configuration",
      box(
        title = "Configuration",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        selectizeInput(
          'ColumnNetworking_From', 
          label = "Select Column for Source", 
          choices = NULL, 
          multiple = FALSE,
          options = list(
            placeholder = 'Select Column for Source'
          )
        ),
        selectizeInput(
          'ColumnNetworking_Target', 
          label = "Select Column for Target", 
          choices = NULL, 
          multiple = FALSE,
          options = list(
            placeholder = 'Select Column for Target'
          )
        ),
        actionButton(inputId = "btnNetwork", label = "Show Network"),
        simpleNetworkOutput("NetworkPlot")
      )
    )
  )
)
