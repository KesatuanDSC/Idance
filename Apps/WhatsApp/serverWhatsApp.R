# --- WhatsApp Server Module ---

output$filesWhatsApp <- renderTable(input$uploadWhatsApp)

dataWhatsApp <- reactive({
  req(input$uploadWhatsApp)
  lines <- vroom::vroom_lines(input$uploadWhatsApp$datapath)
  
  lines <- gsub("\u200e|\u200f", "", lines)
  
  # Deteksi format iPhone
  is_iphone <- any(grepl("^\\[\\d{1,2}/\\d{1,2}/\\d{2},", lines))
  
  if (is_iphone) {
    # === Format iPhone ===
    merged_lines <- c()
    current_line <- ""
    for (line in lines) {
      if (grepl("^\\[\\d{1,2}/\\d{1,2}/\\d{2},", line)) {
        if (nzchar(current_line)) {
          merged_lines <- c(merged_lines, current_line)
        }
        current_line <- line
      } else {
        current_line <- paste(current_line, line)
      }
    }
    if (nzchar(current_line)) {
      merged_lines <- c(merged_lines, current_line)
    }
    
    df <- data.frame(original_text = merged_lines, stringsAsFactors = FALSE) %>%
      mutate(
        bracket_content = str_extract(original_text, "\\[(.*?)\\]"),
        remaining_text = str_remove(original_text, "\\[.*?\\]"),
        bracket_content = str_remove_all(bracket_content, "\\[|\\]")
      ) %>%
      separate(bracket_content, into = c("tanggal", "waktu"), sep = ",", extra = "merge") %>%
      mutate(tanggal = str_trim(tanggal), waktu = str_trim(waktu)) %>%
      mutate(remaining_text = str_trim(remaining_text)) %>%
      separate(remaining_text, into = c("pengirim", "isi_pesan"), sep = ":", extra = "merge") %>%
      select(tanggal, waktu, pengirim, isi_pesan)
    
  } else {
    # === Format Android ===
    df <- lines %>%
      as_tibble() %>%
      filter(grepl("^\\d{1,2}/\\d{1,2}/\\d{2}[,]?\\s+\\d{1,2}[:\\.]\\d{2}", value)) %>%
      mutate(
        raw_tanggal = str_extract(value, "^\\d{1,2}/\\d{1,2}/\\d{2}"),
        raw_waktu = str_extract(value, "(?<= )\\d{1,2}[:\\.]\\d{2}\\s*(am|pm|AM|PM)?"),
        waktu_24 = format(
          suppressWarnings(lubridate::parse_date_time(raw_waktu, orders = c("I:M p", "H:M"))),
          "%H.%M"
        ),
        pesan = str_remove(value, "^\\d{1,2}/\\d{1,2}/\\d{2}[,]?\\s+\\d{1,2}[:\\.]\\d{2}\\s*(am|pm|AM|PM)? - ")
      ) %>%
      mutate(
        tanggal_parsed = coalesce(
          suppressWarnings(mdy(raw_tanggal)),
          suppressWarnings(dmy(raw_tanggal))
        ),
        tanggal = format(tanggal_parsed, "%d/%m/%y")
      ) %>%
      filter(!is.na(tanggal_parsed)) %>%
      mutate(pesan = str_trim(pesan)) %>%
      separate(pesan, into = c("pengirim", "isi_pesan"), sep = ":", extra = "merge", fill = "left") %>%
      filter(!is.na(pengirim) & pengirim != "") %>%
      select(tanggal, tanggal_date = tanggal_parsed, waktu = waktu_24, pengirim, isi_pesan)
    
    
  }
  
  return(df)
})

output$headWhatsApp <- render_gt({
  head(dataWhatsApp(), 10)
})

resultWAComposition <- reactive({
  req(dataWhatsApp())
  df <- dataWhatsApp()
  dfg <- df %>% group_by(pengirim) %>% summarise(total = n())
  dfg7 <- dfg %>% arrange(desc(total)) %>%
    mutate(Grp = ifelse(row_number() <= 7, as.character(pengirim), "Others")) %>%
    group_by(Grp) %>% summarise(Total = sum(total))
})

output$visWAComposition <- renderPlotly({
  req(resultWAComposition())
  dfc <- resultWAComposition()
  plot_ly(dfc, labels = ~Grp, values = ~Total, type = 'pie',
          textinfo='label+percent', insidetextorientation='radial') %>%
    layout(title = "Composition of Top 7 and Others")
})

output$visWAWordCloud <- renderWordcloud2({
  req(dataWhatsApp())
  dfw <- dataWhatsApp()
  stopwords_id <- readLines("stopwords-id.csv")
  dfw$isi_pesan <- gsub("[0-9]", "", dfw$isi_pesan)
  dfw$isi_pesan <- tolower(dfw$isi_pesan)
  dfw$isi_pesan <- gsub("[^[:alpha:][:space:]]", "", dfw$isi_pesan)
  dfw$isi_pesan <- tm::removeWords(dfw$isi_pesan, stopwords_id)
  dfw <- dfw %>% unnest_tokens(word, isi_pesan)
  dfw <- dfw %>% count(word, sort = TRUE)
  dfw <- dfw[1:300, ]
  wordcloud2(dfw, size = 1.5, minSize = 0.5, color = "random-light", backgroundColor = "black", rotateRatio = 1)
})



resultWAHourly <- reactive({
  req(dataWhatsApp())
  df <- dataWhatsApp()
  Sys.setlocale("LC_TIME", "C")
  df$hari <- weekdays(as.Date(df$tanggal, format = '%d/%m/%y'))
  
  df$jam <- str_sub(df$waktu, 1, 2)
  df %>% group_by(jam) %>% summarise(total = n())
})

output$visWAHourly <- renderPlotly({
  req(resultWAHourly())
  dfc <- resultWAHourly()
  plot_ly(x = dfc$jam, y = dfc$total, name = "Hourly Activities", type = "bar")
})

resultWADaily <- reactive({
  req(dataWhatsApp())
  df <- dataWhatsApp()
  Sys.setlocale("LC_TIME", "C")
  df$hari <- weekdays(as.Date(df$tanggal, format = '%d/%m/%y'))
  
  df %>% group_by(hari) %>% summarise(total = n())
})

output$visWADaily <- renderPlotly({
  req(resultWADaily())
  dfc <- resultWADaily()
  plot_ly(x = dfc$hari, y = dfc$total, name = "Daily Activities", type = "bar")
})

TheInsight <- eventReactive(input$WAInsight, {
  req(dataWhatsApp(), input$WAPeriode)
  df <- dataWhatsApp()
  df <- df %>% filter(str_sub(tanggal, 4, 8) == input$WAPeriode)
  df$story <- paste(df$pengirim, 'berkata', df$isi_pesan)
  merged_text <- paste(df$story, collapse = "\n")
  user_prompt <- str_sub(merged_text, start = -50000)
  gemini_completion(user_prompt, 'Story')  # atau ganti dengan generate_completion jika pakai OpenAI
})

output$WAExplanation <- renderText({
  req(TheInsight())
  TheInsight()
})

output$downloadWAInsight <- downloadHandler(
  filename = function() {
    paste("WhatsApp_Insight_", Sys.Date(), ".txt", sep = "")
  },
  content = function(file) {
    writeLines(TheInsight(), file)
  }
)

resultWATSMonthlyYearly <- reactive({
  req(dataWhatsApp())
  df <- dataWhatsApp()
  df$bulan <- strftime(as.Date(df$tanggal, format = '%d/%m/%y'), '%m')
  df$tahun <- strftime(as.Date(df$tanggal, format = '%d/%m/%y'), '%Y')
  df$periode <- paste(df$tahun, "/", df$bulan)
  df %>% group_by(periode) %>% summarise(total = n()) %>% arrange(periode)
})

output$visWATSMonthlyYearly <- renderPlotly({
  req(resultWATSMonthlyYearly())
  dfc <- resultWATSMonthlyYearly()
  plot_ly(x = dfc$periode, y = dfc$total, name = "Monthly Activities",
          type = "bar", source = "WADetailMonthly") %>%
    event_register("plotly_click")
})

datadetailWAMonthlyYearly <- eventReactive(event_data("plotly_click", source = "WADetailMonthly"), {
  event_data("plotly_click", source = "WADetailMonthly")
})

observeEvent(datadetailWAMonthlyYearly(), {
  FullData <- dataWhatsApp()
  Terpilih <- datadetailWAMonthlyYearly()
  Selected <- Terpilih$x
  xperiode <- sub("^(\\d{4}) / (\\d{2})$", "\\2/\\1", Selected)
  Hasil <- FullData %>% filter(str_sub(tanggal, 4, 8) == xperiode) %>%
    select(tanggal, waktu, pengirim, isi_pesan)
  showModal(modalDialog(
    title = "Message Detail",
    renderDataTable({
      DT::datatable(Hasil, selection = "single")
    }),
    size = "xl"
  ))
})
