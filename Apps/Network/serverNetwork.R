output$filesNetwork <- renderTable(input$uploadNetwork)

dataNetwork <- reactive({
  req(input$uploadNetwork)
  
  ext <- tools::file_ext(input$uploadNetwork$name)
  switch(ext,
         csv = vroom::vroom(input$uploadNetwork$datapath, delim = ","),
         tsv = vroom::vroom(input$uploadNetwork$datapath, delim = "\t"),
         xlsx = read.xlsx(input$uploadNetwork$datapath, sheet = 1),
         validate("Invalid file; Please upload a .csv or .tsv file")
  )
})

output$headNetwork <- render_gt({
  head(dataNetwork(), 10)
})

selectableFeatureNetworkingSource <- reactive({
  req(dataNetwork())
  colnames(dataNetwork())
})

selectableFeatureNetworkingTarget <- reactive({
  req(dataNetwork())
  colnames(dataNetwork())
})

observe({
  updateSelectizeInput(session, 'ColumnNetworking_From', choices = selectableFeatureNetworkingSource(), server = TRUE)
  updateSelectizeInput(session, 'ColumnNetworking_Target', choices = selectableFeatureNetworkingTarget(), server = TRUE)
})

TheNetwork <- eventReactive(input$btnNetwork, {
  data <- dataNetwork()[, c(input$ColumnNetworking_From, input$ColumnNetworking_Target)]
  p <- simpleNetwork(data, height="100px", width="100px",        
                     Source = 1,                 # column number of source
                     Target = 2,                 # column number of target
                     linkDistance = 10,          # distance between node. Increase this value to have more space between nodes
                     charge = -900,                # numeric value indicating either the strength of the node repulsion (negative value) or attraction (positive value)
                     fontSize = 14,               # size of the node names
                     fontFamily = "serif",       # font og node names
                     linkColour = "#666",        # colour of edges, MUST be a common colour for the whole graph
                     nodeColour = "#69b3a2",     # colour of nodes, MUST be a common colour for the whole graph
                     opacity = 0.9,              # opacity of nodes. 0=transparent. 1=no transparency
                     zoom = T                    # Can you zoom on the figure?
  )
})

output$NetworkPlot <- renderSimpleNetwork({
  TheNetwork()
})

