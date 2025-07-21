# Load packages
library(shiny)
library(shinyjs)
library(bs4Dash)
library(thematic)
library(waiter)
library(glue)
library(vroom)
library(tools)
library(gt)
library(DT)
library(openxlsx)
library(plotly)
library(factoextra)
library(igraph)
library(networkD3)
library(dplyr)
library(ggplot2)
library(openai)
library(stringr)
library(httr)
library(shinycssloaders)
library(MUS)
library(stringdist)
library(tidyverse)
library(benford.analysis)
library(wordcloud2)
library(tidytext)
library(tm)
library(gemini.R)

# Set automatic theming
thematic_shiny()

# Load external functions & UI modules
source("Functionx.R")
source("Apps/Home/uiHome.R")
source("Apps/Clustering/uiClustering.R")
source("Apps/Network/uiNetwork.R")
source("Apps/Regression/uiRegression.R")
source("Apps/FuzzyDup/uiFuzzyDup.R")
source("Apps/Benford/uiBenford.R")
source("Apps/WhatsApp/uiWhatsApp.R")

# Run the app
shinyApp(
  
  # --- UI ---
  ui <- dashboardPage(
    preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#343a40"),
    dark = FALSE,
    help = NULL,
    scrollToTop = TRUE,
    
    header = dashboardHeader(
      fixed = TRUE,
      title = NULL,
      skin = "dark"
    ),
    
    sidebar = dashboardSidebar(
      fixed = TRUE,
      skin = "light",
      status = "warning",
      id = "sidebar",
      sidebarMenu(
        id = "current_tab",
        flat = FALSE,
        compact = FALSE,
        childIndent = TRUE,
        menuItem("Home", tabName = "iHome", icon = icon("home")),
        menuItem("Interactive Clustering", tabName = "iClustering", icon = icon("object-group")),
        menuItem("Network Graph", tabName = "iNetwork", icon = icon("diagram-project")),
        menuItem("Regression", tabName = "iRegression", icon = icon("chart-line")),
        menuItem("Fuzzy Duplicate", tabName = "iFuzzyDup", icon = icon("check-double")),
        menuItem("Benford Analysis", tabName = "iBenford", icon = icon("magnifying-glass-dollar")),
        menuItem("WhatsApp Analysis", tabName = "iWhatsApp", icon = icon("whatsapp"))
      )
    ),
    
    dashboardBody(
      tags$head(
        tags$style(HTML("
      .custom-navbar {
        width: 100%;
        height: 70px;
        background-color: #FFB300;
        display: flex;
        align-items: center;
        padding: 0 20px;
        position: fixed;
        top: 0;
        left: 0;
        z-index: 1050;
      }

      .custom-navbar img {
        height: 60px;
        margin-right: 15px;
      }

      .custom-navbar-title {
        color: black;
      }

      .main-sidebar {
        margin-top: 12px !important;
      }

      .content-wrapper {
        margin-top: 60px !important;
      }

      .main-header {
        background-color: transparent !important;
        height: 0px !important;
        overflow: visible !important;
      }

      .main-header .navbar {
        background-color: transparent !important;
        height: 0px;
        overflow: visible;
      }

      .main-header .navbar .nav-item {
        margin-top: 60px !important;
      }
      
      .form-check-input {
        width: 2.5em;
        height: 1.5em;
        background-color: #ccc;
        border-radius: 1em;
        position: relative;
        appearance: none;
        cursor: pointer;
        transition: background-color 0.25s ease;
      }
    
      .form-check-input:checked {
        background-color: #343a40;
      }
    
      .form-check-input::before {
        content: '';
        position: absolute;
        top: 0.2em;
        left: 0.2em;
        width: 1.1em;
        height: 1.1em;
        background-color: white;
        border-radius: 50%;
        transition: transform 0.25s ease;
      }
    
      .form-check-input:checked::before {
        transform: translateX(1em);
      }
      
      .dark-mode .main-sidebar {
        background-color: #343a40 !important;
        color: #ffffff !important;
      }
      
      .dark-mode .main-sidebar .nav-sidebar > .nav-item > .nav-link {
        color: #ffffff !important;
      }
      
      .dark-mode .main-sidebar .nav-sidebar > .nav-item > .nav-link.active {
        background-color: #FFB300 !important;
        color: #000 !important;
      }
        
        #Box .card-header {
          background-color: #FFEB7A !important;
        }
      
        #Box .card-header .card-title {
          color: black !important;
          font-weight: bold;
        }

        .card-warning:not(.card-outline)>.card-header {
            background-color: #FFEB7A;
        }
        }

    ")),
        tags$script(HTML("
          $(document).on('change', '#dark_mode', function() {
            if ($(this).is(':checked')) {
              $('body').addClass('dark-mode');
            } else {
              $('body').removeClass('dark-mode');
            }
          });
        "))
      ),
      tags$div(
        class = "custom-navbar",
        style = "display: flex; align-items: center; justify-content: space-between; width: 100%; padding: 0 20px;",
        
        # KIRI: Logo + Judul + Tombol Sidebar
        tags$div(
          style = "display: flex; align-items: center;",
          
          # Logo
          tags$img(src = "LogoBPK.png", height = "60px", style = "margin-right: 10px;"),
          
          # Judul + Subjudul
          tags$div(
            style = "display: flex; flex-direction: column;",
            tags$h2("iDANCE", class = "custom-navbar-title", style = "margin: 0; font-weight: bold;"),
            tags$span("Interactive Data Analytics Center", class = "custom-navbar-title", style = "font-size: 15px;")
          ),
          
          # Sidebar Toggle
          tags$button(
            id = "toggleSidebar",
            class = "btn btn-link",
            icon("bars", class = "fa-lg"),
            style = "color: black; margin-left: 20px;",
            onclick = "document.body.classList.toggle('sidebar-collapse')"
          )
        ),
        
        # KANAN: Icon Bulan + Toggle Switch
        tags$div(
          style = "display: flex; align-items: center; gap: 8px;",
          
          # Toggle Switch (di kiri)
          tags$input(
            class = "form-check-input",
            type = "checkbox",
            id = "dark_mode"
          ),
          
          # Icon Bulan (di kanan)
          tags$i(class = "fas fa-moon", style = "color: black; font-size: 18px; position: relative; top: 2px;")
        )
      ),
      
      
      tabItems(
        iHome_tab,
        iClustering_tab,
        iNetwork_tab,
        iRegression_tab,
        iFuzzyDup_tab,
        iBenford_tab,
        iWhatsApp_tab
      )
    ),
    
    
    
    
    footer = dashboardFooter(
      fixed = FALSE,
      left = a(
        href = "https://www.linkedin.com/company/kesatuan-data-science-center/",
        target = "_blank", "@KDSC"
      ),
      right = "© 2025 Kesatuan Data Science Center. All rights reserved."
    )
  ),
  
  # --- SERVER ---
  server = function(input, output, session) {
    useAutoColor()
    
    # Load each server module
    source("Apps/Home/serverHome.R", local = TRUE)
    source("Apps/Clustering/serverClustering.R", local = TRUE)
    source("Apps/Network/serverNetwork.R", local = TRUE)
    source("Apps/Regression/serverRegression.R", local = TRUE)
    source("Apps/FuzzyDup/serverFuzzyDup.R", local = TRUE)
    source("Apps/Benford/serverBenford.R", local = TRUE)
    source("Apps/WhatsApp/serverWhatsApp.R", local = TRUE)
    
    # Controlbar toggle
    observeEvent(input$controlbar, {
      toastOpts <- list(
        autohide = TRUE,
        icon = "fas fa-home",
        close = FALSE,
        position = "bottomRight",
        class = if (input$controlbar) "bg-success" else "bg-danger"
      )
      toast(
        title = if (input$controlbar) "Controlbar opened!" else "Controlbar closed!",
        options = toastOpts
      )
    })
    
    observeEvent(input$controlbarToggle, {
      updateControlbar(id = "controlbar")
    })
    
    observeEvent(input$sidebarToggle, {
      updateSidebar(id = "sidebar")
    })
  }
)
