#' Regression Tab ----
iRegression_tab <- tabItem(
  tabName = "iRegression",
  box(
    title = "Regression",
    status = "warning",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    height = "100%",
    fileInput("uploadRegression", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
    uiOutput("varSelectUI"),
    fluidRow(
      column(
        width = 6,
        box(
          title = "Regression Summary",
          status = "warning",
          id = "Box",
          solidHeader = TRUE,
          collapsible = TRUE,
          width = 12,
          height = "100%",
          verbatimTextOutput("regSummary") %>% withSpinner(color = "#5bc0de")
        )
      ),
      column(
        width = 6,
        box(
          title = "Regression Plot",
          status = "warning",
          id = "Box",
          solidHeader = TRUE,
          collapsible = TRUE,
          width = 12,
          height = "100%",
          plotOutput("regressionPlot") %>% withSpinner(color = "#5bc0de")
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        box(
          title = "Explanation",
          collapsed = TRUE,
          status = "warning",
          id = "Box",
          solidHeader = TRUE,
          collapsible = TRUE,
          width = 12,
          height = "100%",
          verbatimTextOutput("regExplanation") %>% withSpinner(color = "#5bc0de"),
          downloadButton("downloadregExplanation", "Download Explanation")
        )
      ),
    )
  )
)
