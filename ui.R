library(shiny)
library(bslib)
library(shinydashboard)
library(fresh)

TOTA_theme <- create_theme(
  adminlte_color(
    light_blue = "#004B55"
  )
)

footer_TOTA <- tags$footer( 
  tags$style(HTML("
    @media (max-width: 600px) {
      #footer-logo img {
        min-width: 60px;
      }
      #footer-text p {
        font-size: 12px !important;
      }
      #footer-credit p {
        font-size: 11px !important;
      }
    }
  ")),
  div(
    div(
      tags$img(
        src = "side_bar_logo.png",
        width = "80%",
        style = "display: block; margin: 0 auto;"
      ),
      id = "footer-logo",
      style = "width: 15%; display: flex; align-items: center; justify-content: center;"
    ),
    
    div(
      p("Thompson Okanagan Tourism Association",
        style = "font-weight: bold; margin-bottom: 5px;"
      ),
      
      tags$a(
        "www.totabc.org",
        href = "https://www.totabc.org/",
        target = "_blank",
        style ="color: white;"
      ),
      
      
      p("2280-D Leckie Road, Kelowna,",
        style = "margin-bottom: 2px;"
      ),
      
      p("British Columbia, V1X 6G6",
        style = "margin-bottom: 0;"
      ),
      id = "footer-text",
      style = "width: 60%; color: white; display: flex; flex-direction: column; justify-content: center; padding-left: 5%;"
    ),
    
    div(
      tags$p(
        tags$a(
          "Created by Alexis Samp",
          href = "https://ca.linkedin.com/in/alexis-samp-b89678342",
          target = "_blank",
          style ="color: white;"
        ),
        style = "color: white; width: 100%; font-size: 14px; text-align: center; text-decoration: underline;"
      ),
      id = "footer-credit"
    ),
    style = "width: 100%; background-color: #004B55; display: flex; align-items: center; padding: 20px 5%; box-sizing: border-box; color: white;"
  ),
  style = "position: relative; bottom: 0; left: 0; width: 100%; z-index: 9999;"
)

ui <- dashboardPage(
  dashboardHeader(title = "Solid Waste Dashboard"),
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Overview", tabName = "overview", icon = icon("readme")),
      menuItem("Tab 1", tabName = "tab_1", icon = icon("square-poll-vertical")),
      menuItem("Tab 2", tabName = "tab_2", icon = icon("droplet"))
    ),
    
    tags$img(
      src = "side_bar_logo.png",
      width = "85%",
      style = "display: block; margin: 0 auto; padding-top: 40px;"
    ),
    
    tags$img(
      src = "UN_side_bar_logo.png",
      width = "85%",
      style = "display: block; margin: 0 auto; padding-top: 40px;"
    )
  ),
  
  dashboardBody(
    use_theme(TOTA_theme),
    
    tabItems(
      
      tabItem(
        
        tabName = "overview",
        
        fluidRow(
          width = "100%",
          
          column(
            width = 12,
            h2("About this Dashboard"),
            
            p("The purpose of this dashboard is to support TOTA's soild waste management reporting for the ", 
              tags$a(
                href = "https://www.untourism.int/observatories/thompson-okanagan",
                "UN Tourism International Network of Sustainable Tourism Observatories (INSTO)",
                target = "_blank",
                style ="color: #76ACA9; text-decoration: underline;"
              ), " and contribute to ongoing efforts to better understand the relationship between 
               solid waste and tourism in the Thompson-Okanagan. "),
            style = "font-size: 18px;"
          )
        )
      ),
      tabItem(
        tabName = "tab_1"
      ),
      
      tabItem(
        tabName = "tab_2"
      )
    ),
    footer_TOTA
  )
)