#' Benford Analysis Tab ----
iBenford_tab <- tabItem(
  tabName = "iBenford",
  box(
    title = "Benford Analysis",
    status = "warning",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    height = "100%",
    fileInput("uploadBenford", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
    uiOutput("varSelectUIBenford"),
    tabBox(
      id = "Benford",
      title = "Benfrod Analysis",
      elevation = 2,
      width = 12,
      collapsible = FALSE, 
      closable = FALSE,
      type = "tabs",
      status = "warning",
      solidHeader = TRUE,
      selected = "Benford Plot",
      tabPanel(
        "Benford Plot",
        plotOutput("PlotBenford") %>% withSpinner(color = "#0dc5c1"),
      ),
      tabPanel(
        "Suspected Records",
        DTOutput("BenfordResult") %>% withSpinner(color = "#0dc5c1")
      )
    )
  )
)
