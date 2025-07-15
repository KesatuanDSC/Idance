#' Fuzzy Duplicate Tab ----
iFuzzyDup_tab <- tabItem(
  tabName = "iFuzzyDup",
  box(
    title = "Fuzzy Duplicate",
    status = "warning",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    height = "100%",
    fileInput("uploadFuzzyDup", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
    uiOutput("varSelectUIFD"),
    
    fluidRow(
      column(
        width = 12,
        box(
          title = "Result",
          collapsed = FALSE,
          status = "warning",
          id = "Box",
          solidHeader = TRUE,
          collapsible = TRUE,
          width = 12,
          height = "100%",
          DTOutput("tableFuzzyDup") %>% withSpinner(color = "#FFEB7A")
        )
      )
    )
  )
)
