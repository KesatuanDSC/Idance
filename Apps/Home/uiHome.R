# Home Page
iHome_tab <- tabItem(
  tabName = "iHome",
  box(
    title = "Home",
    id = "Box",
    solidHeader = TRUE,
    collapsible = TRUE,
    width = 12,
    height = "100%",
    htmlOutput("homeText")
  )
)
