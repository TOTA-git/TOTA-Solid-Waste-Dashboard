library(shiny)
library(bslib)
library(shinydashboard)
library(fresh)

TOTA_theme <- create_theme(
  adminlte_color(
    light_blue = "#004B55",
    yellow = "#BCB49E",
    orange = "#F6BC1A",
    teal = "#76ACA9",
    fuchsia = "#D11B4A"
    #red, yellow, aqua, blue, light-blue, green, navy, teal, olive, lime, orange, fuchsia, purple, maroon, black.
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
  dashboardHeader(
    title = "Solid Waste Dashboard",
    tags$li(
      class = "dropdown",
      tags$a(
        href = "https://www.totabc.org/",
        icon("globe"),
        " TOTA INSTO HUB",
        style = "
        color: white;
        font-size: 18px;
        padding: 15px;
        text-decoration: underline;",
      )
    )             
  ),
  
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Overview", tabName = "overview", icon = icon("readme")),
      menuItem("Disposal Rates", tabName = "disposal_rates", icon = icon("trash-can")),
      menuItem("Organic Waste", tabName = "organic", icon = icon("carrot")),
      menuItem("Back to Hub", tabName = NULL, icon = icon("globe"), href = "https://www.totabc.org/")
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
        
        # tags$img(
        #   src = "banner.png",
        #   width = "100%",
        #   style = "position: relative;"
        # ),
        
        fluidRow(
          width = "100%",
          
          column(
            width = 12,
            h2("About this Dashboard"),
            
            p(
              "The purpose of this dashboard is to support TOTA's soild waste management reporting for the ",
              tags$a(
                href = "https://www.untourism.int/observatories/thompson-okanagan",
                "UN Tourism International Network of Sustainable Tourism Observatories (INSTO)",
                target = "_blank",
                style = "color: #76ACA9; text-decoration: underline;"
              ),
              " and contribute to ongoing efforts to better understand the relationship between
               solid waste and tourism in the Thompson Okanagan Region. "
            ),
            br(),
            style = "font-size: 18px;"
          ),
          
          column(
            tags$head(tags$style(
              HTML(
                ".explore-link {
                                    display: block;
                                    font-size: 18px;
                                    font-weight: 600;
                                    margin-top: 10px;
                                    margin-bottom: 10px;
                                    color: #004B55;
                                    text-decoration: none;
                                  }
                                  .explore-link:hover {
                                    text-decoration: underline;
                                    cursor: pointer;
                                  }
                                "
              )
            )),
            
            width = 12,
            h2("What Can Be Explored?"),
            
            actionLink(
              "disposal_rates_link",
              strong("Disposal Rates - How much waste is being disposed??"),
              class = "explore-link",
              
            ),
            p(
              "Explore disposal rates and total waste disposed. Compare changes of the years and to B.C. as a whole."
            ),
            
            actionLink(
              "organic_link",
              strong(
                "Organic Waste - What compost facilities exist and what do they accept?"
              ),
              class = "explore-link"
            ),
            p(
              "View compost production facilities throughout the Thompson Okanagan and the accepted organic materials."
            ),
            br()
          ),
          
          tags$style(
            HTML(
              ".explore-link {
                              color: #42817A;
                              font-size: 20px;
                              font-weight: bold;
                              text-decoration: none;
                            }

                            .explore-link:hover {
                              text-decoration: underline;
                            }
                          "
            )
          ),
          style = "width: 100%; padding: 20px; font-size: 18px;"
        )
      ), 
      tabItem(
        tabName = "disposal_rates",
        
        tags$style(HTML("
          @media (max-width: 600px) {
            #MunicipalWasteMap { height: 350px !important; }
            #DisposalRateBarPlot { height: 350px !important; }
            #HistoricalBarPlot { height: 350px !important;}
          }
        ")),
        
        fluidRow(
          box(
            title = "Disposal Rates - How much waste is being disposed?",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            p("The data below focuses on municipal solid waste disposal across the Thompson Okanagan Tourism Region, 
              represented by the regional districts that make up the area: Thompson-Nicola, 
              North Okanagan, Central Okanagan, Okanagan-Similkameen, Columbia-Shuswap, Kootenay Boundary, and Fraser-Fort George."),
            p("The regional districts make up an area greater than the Thompson Okangan Tourism Region,
               therefore the amount of waste disposed is overestimated."),
            p(paste0(format(BC_total_recent, big.mark = ","), " tonnes of municipal solid waste was disposed if in B.C.", " in ", max(df_municipal_waste_disposed_TO$Year),
                     ". The Thompson Okanagan Tourism Region disposed of approximately ", format(TO_total_recent, big.mark = ","), " tonnes, contributing ", round((TO_total_recent/BC_total_recent) * 100, digits = 2), "%"), 
              " to B.C. total waste disposed."),
            style = "font-size: 18px;"
          ),
          
          infoBox(
            title = "",
            width = 6,
            color = "light-blue",
            icon = icon("filter"),
            value = div(
              selectInput(
                "year",
                "Select Year:",
                choices = sort(unique(df_municipal_waste_disposed$Year)),
                selected = max(df_municipal_waste_disposed$Year),
              )
            )
          ),
          
          infoBox(
            title = "Data Freshness",
            width = 6,
            color = "light-blue",
            icon = icon("clock-rotate-left"),
            value = textOutput("data_last_updated_WD"),
            subtitle = "Data is updated annually by the B.C. Ministry of Environment and Parks"
          ),
          
          valueBoxOutput("TotalWasteRecentYear", width = 3),
          valueBoxOutput("TotalBCtoTO", width = 3),
          valueBoxOutput("YoY", width = 3),
          valueBoxOutput("WastePerCapita", width = 3),

          box(
            title = "Select a Region",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 6,
            leafletOutput("MunicipalWasteMap", height = 500),
          ),
          
          box(
            title = "Which Region has the Highest Disposal Rate?",
            subtitle = "Put bar chart here",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 6,
            plotlyOutput("DisposalRateBarPlot", height = 500)
          ),
          
          uiOutput("HistoricalBarPlotBox"),
          
          uiOutput("RegionTableBox"),
          
          box(
            title = "About the Data",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 6,
            p("This dashboard uses municipal solid waste disposal data published by Environmental Reporting BC. 
              The dataset provides estimated annual municipal solid waste disposal amounts for British Columbia’s 
              regional districts and is reported as both total waste disposed and kilograms per person. Data is 
              provided primarily by regional districts, with population estimates sourced from BC Stats."),
            h4("What is included?"),
            p("The disposal rate includes waste from residential, institutional, commercial, and light industrial 
              sources, as well as construction, renovation, and demolition activities. It does not include hazardous, 
              biomedical, agricultural, heavy industrial waste, motor vehicles or components, contaminated soil, 
              or materials that are reused or recycled."),
            h4("Interpreting the data"),
            p("Differences in disposal rates between regions can be influenced by population density, economic activity,
              tourism and transient populations, access to recycling markets, waste-management infrastructure, and other
              regional factors. Historical data should also be interpreted with caution because collection methods have 
              changed over time. The Province notes that data from 2012 onward were collected using the same methodology,
              making this period more appropriate for assessing trends. Where data are unavailable, a verifiable estimate was not available."),
            p("For more details: ",
              tags$a(
                href = "https://www.env.gov.bc.ca/soe/indicators/sustainability/municipal-solid-waste.html",
                tags$button(
                  type = "button",
                  "Environmental Reporting BC"
                )
              )
            ),
          ),
          
          box(
            title = "References",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            p("Data source: Province of British Columbia. BC Municipal Solid Waste Disposal Rates. 
              Retrieved from https://catalogue.data.gov.bc.ca/dataset/bc-municipal-solid-waste-disposal-rates "),
            p("Data source: Province of British Columbia. BC Tourism Regions. 
              Retrieved from https://catalogue.data.gov.bc.ca/dataset/bc-tourism-regions"),
            p("Environmental Reporting BC. Municipal Solid Waste Disposal in B.C. State of Environment 
              Reporting, Ministry of Environment and Parks, British Columbia, Canada."),
            
          )
        )
      ),
      
      tabItem(
        tabName = "organic",
        
        tags$style(HTML("
          @media (max-width: 600px) {
            #OrganicsAcceptedPlot { height: 350px !important; }
          }
        ")),
        
        fluidRow(
          box(
            title = "Organic Waste - What compost facilities exist and what do they accept?",
            p("This data provides an overview of facilities that receive and manage organic waste across the Thompson Okanagan Tourism Region. 
              This includes facility locations, the organic materials they accept and do not accept, and facility capacities.
            Facilities that accept food, brewery, and winery waste contributes to soild waste management for tourism-related activities such as eating out at restaurants 
              and visiting breweries and wineries."),
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            style = "font-size: 18px;"
          ),

          valueBoxOutput("NumActive", width = 4),
          valueBoxOutput("PrecentFoodWaste", width = 4),
          valueBoxOutput("PrecentBreweryWaste", width = 4),
          
          infoBox(
            title = "Data Freshness",
            width = 6,
            color = "light-blue",
            icon = icon("clock-rotate-left"),
            value = paste0("Last Modified: ", format(df_OW_lastModified$`data$lastModified`, "%B %d, %Y"))
          ),
          infoBox(
            title = "Info",
            width = 6,
            color = "light-blue",
            icon = icon("circle-info"),
            value = p("The eligible organic material catagories are based on the ",
                      tags$a(
                        href = "https://www.bclaws.gov.bc.ca/civix/document/id/complete/statreg/18_2002",
                        "Organic Matter Recycling Regulation (OMRR)",
                        target = "_blank",
                        style ="color: #76ACA9; text-decoration: underline;"
                      ),
                      " defined under Schedule 12, Organic Matter Suitable for Composting. A facility doesn't necessarily accept every material on that list.",
                      style = "font-size: 14px; font-weight: normal;"),
          ),

          box(
            title = "Active Compost Facilities",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 6,
            leafletOutput("OrganicWasteMap", height = 500),
            uiOutput("DynamicTableBox")
          ),
          
          box(
            title = "Number of Facilities Accepting Each Organic Material",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 6,
            plotlyOutput("OrganicsAcceptedPlot", height = 539),
            subtitle = ""
          ),

          box(
            title = "References",
            solidHeader = TRUE,
            collapsible = TRUE,
            width = 12,
            p("Data source: Province of British Columbia. Organic Matter Recycling Regulation. Retrieved from https://organicsinfo.gov.bc.ca/api/omrr" ),
            p("Organics Info. Province of British Columbia. https://organicsinfo.gov.bc.ca/"),
            p("Organic Matter Recycling Regulation. Environmental Management Act and Public Health Act. https://www.bclaws.gov.bc.ca/civix/document/id/complete/statreg/18_2002")
          )
        )
      )
    ),
    footer_TOTA
  )
)