# Monetary Unit Sampling Tab ----
iSampling_tab <- tabItem(
  tabName = "iSampling",
  box(
    title = "Statistical Sampling",
    status = "warning",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    height = "100%",
    fileInput("uploadMUS", "Upload a file", accept = c(".csv", ".tsv",".xlsx")),
    tabBox(
      id = "Sampling",
      title = "Statistical Sampling",
      elevation = 2,
      width = 12,
      collapsible = FALSE, 
      closable = FALSE,
      type = "tabs",
      status = "warning",
      solidHeader = TRUE,
      selected = "MUS",
      tabPanel(
        "MUS",
        uiOutput("varSelectColumnMUS"),
        fluidRow(
          column(
            width = 3,
            sliderInput("sliderConf", "Confidence Level in %", min = 0, max = 100, value = 95)
          ),
          column(
            width = 3,
            sliderInput("sliderTE", "Tolerable Error in %", min = 0, max = 100, value = 15)
          ),
          column(
            width = 3,
            sliderInput("sliderEE", "Expected Error in % of TE", min = 0, max = 100, value = 10)
          ),
          column(
            width = 3,
            numericInput("MinSize", "Minimum Sample Size", value = 10)
          )
        ),
        actionButton(inputId = "runMUS", label = "Extract Sample"),
        DTOutput("musTable") %>% withSpinner(color = "#0dc5c1")
      ),
      tabPanel(
        "Random Sampling",
        numericInput("MinSizeRandom", "Required Sample Size", value = 10),
        actionButton(inputId = "runRandom", label = "Extract Sample"),
        DTOutput("randomTable") %>% withSpinner(color = "#0dc5c1")
      ),
      tabPanel(
        "Stratified Sampling",
        uiOutput("varSelectColumnStrata"),
        sliderInput("sliderStratSize", "Sample Size (%)", min = 0, max = 100, value = 50),
        actionButton(inputId = "runStrata", label = "Extract Sample"),
        DTOutput("StrataTable") %>% withSpinner(color = "#0dc5c1")
      )
    )
  ),
  box(
    title = "Evaluation",
    status = "warning",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    collapsed = TRUE,
    width = 12,
    height = "100%",
    DTOutput("samplingEvaluation") %>% withSpinner(color = "#0dc5c1")
  )
)
