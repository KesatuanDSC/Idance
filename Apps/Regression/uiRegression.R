#' Regression Tab ----
iRegression_tab <- tabItem(
  tabName = "iRegression",
  tabBox(
    title = "Regression",
    elevation = 2,
    id = "Box",
    width = 12,
    collapsible = TRUE, 
    closable = FALSE,
    type = "tabs",
    status = "warning",
    solidHeader = TRUE,
    selected = "Regression",
    # Preparation Tab ----
    tabPanel(
      "Regression",
      box(
        title = "Regression",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        fileInput("uploadRegression", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
        uiOutput("varSelectUI")
      ),
      fluidRow(
        column(
          width = 12,
          box(
            title = "Regression Plot",
            id = "Box",
            status = "warning",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            height = "100%",
            plotlyOutput("regressionPlot") %>% withSpinner(color = "#FFEB7A")
          )
        )
      )
    ),
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
        verbatimTextOutput("regSummary")
      )
    ),
    tabPanel(
      "Explanation",
      box(
        "Explanation",
        title = "Explanation",
        status = "warning",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        id = "Box",
        verbatimTextOutput("regExplanation") %>% withSpinner(color = "#FFEB7A"),
        downloadButton("downloadregExplanation", "Download Explanation")
      )
    )
  )
)
