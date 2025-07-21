iWhatsApp_tab <- tabItem(
  tabName = "iWhatsApp",
  tabBox(
    title = "WhatsApp Analysis",
    elevation = 2,
    id = "tabcard1",
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
        id = "Box",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        fileInput("uploadWhatsApp", "Upload a file", accept = ".txt"),
        tableOutput("filesWhatsApp"),
        plotlyOutput("visWAComposition") %>% withSpinner(color = "#5bc0de")
      )
    ),
    tabPanel(
      "Analysis",
      fluidRow(
        column(
          width = 12,
          box(
            title = "WordCloud",
            collapsed = FALSE,
            status = "warning",
            id = "Box",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            height = "100%",
            wordcloud2Output("visWAWordCloud") %>% withSpinner(color = "#5bc0de")
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          box(
            title = "Hourly Activities",
            collapsed = FALSE,
            status = "warning",
            id = "Box",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            height = "100%",
            plotlyOutput("visWAHourly") %>% withSpinner(color = "#5bc0de")
          )
        ),
        column(
          width = 6,
          box(
            title = "Daily Activities",
            collapsed = FALSE,
            status = "warning",
            id = "Box",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            height = "100%",
            plotlyOutput("visWADaily") %>% withSpinner(color = "#5bc0de")
          )
        )
      ),
    ),
    tabPanel(
      "Time Series",
      box(
        title = "Time Series Analysis (Monthly)",
        collapsed = FALSE,
        status = "warning",
        id = "Box",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        height = "100%",
        plotlyOutput("visWATSMonthlyYearly") %>% withSpinner(color = "#5bc0de")
      )
    ),
    tabPanel(
      "Insight",
      fluidRow(
        column(
          width = 12,
          box(
            title = "Insight",
            collapsed = FALSE,
            status = "warning",
            id = "Box",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            height = "100%",
            textInput("WAPeriode", "Select Period [MM/YY]", value = "04/25"),
            actionButton("WAInsight", "Get Insight"),
            verbatimTextOutput("WAExplanation") %>% withSpinner(color = "#5bc0de"),
            downloadButton("downloadWAInsight", "Download Insight")
          )
        )
      )
    )
  )
)


