server <- function(input, output, session) {
  
  #DISPOSAL RATE PAGE ==================================================================================================
  
  #DATE THE MUNICIPAL_WASTE_DISPOSED WAS LAST UPDATED BY ENVIRONMENTAL REPORTING BC IN DATA CATALOGUE
  output$data_last_updated_WD <- renderText({
    metadata <- fromJSON(
      "https://catalogue.data.gov.bc.ca/api/3/action/resource_show?id=d2648733-e484-40f2-b589-48192c16686b"
    )
    paste("Last Updated:",
      format(
        as.Date(metadata$result$last_modified),
        "%B %d, %Y"
      )
    )
  })
  
  #VALUE BOX OF TOTAL WASTE DISPOSED IN THE T-O AREA FOR THE SELECED YEAR
  output$TotalWasteRecentYear <- renderValueBox({
    
    total <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      summarise(total = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(total)
    
    if(total == 0){
      valueBox(
        value = icon("minus"),
        subtitle = paste0("No data for ", input$year),
        icon = icon("trash"),
        color = "orange"
      )
    } else {
      valueBox(
        value = paste0(format(round(total), big.mark = ","), " tonnes"),
        subtitle = paste0("Total waste disposed for ", input$year),
        icon = icon("trash"),
        color = "orange"
      )
    }
  })
  
  #THE % OF WASTE T-O CONTRIBUTED TO BCs TOTAL WASTE DISPOSED
  output$TotalBCtoTO <- renderValueBox({
    
    BC_total <- df_municipal_waste_disposed %>%
      filter(Year == input$year) %>%
      summarise(BC_total = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(BC_total)

    TO_total <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      summarise(TO_total = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(TO_total)
    
    TO_precentage <- (TO_total/BC_total)*100
    
    if(BC_total == 0 || TO_total == 0){
      valueBox(
        value = icon("minus"),
        subtitle = paste0("No data for ", input$year),
        icon = icon("scale-unbalanced"),
        color = "teal"
      )
    } else {
      valueBox(
        value = paste0(round(TO_precentage, digits = 2), "%"),
        subtitle = paste0("Of B.C. total waste disposed for ", input$year),
        icon = icon("scale-unbalanced"),
        color = "teal"
      )
    }

  })
  
  #YOY GROWTH OF AMOUNT DISPOSED
  output$YoY <- renderValueBox({
    
    selected_year <- as.numeric(input$year)
    
    current_period <- df_municipal_waste_disposed_TO %>%
      filter(Year == selected_year) %>%
      summarise(current_period = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(current_period)
    
    prev_period <- df_municipal_waste_disposed_TO %>%
      filter(Year == selected_year -1) %>%
      summarise(prev_period = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(prev_period)
    
    YoY_growth <- ((current_period - prev_period) / prev_period) * 100

    if(prev_period == 0 || current_period == 0){
      valueBox(
        value = icon("minus"),
        subtitle = paste0("No data for ", input$year),
        icon = icon("xmark"),
        color = "orange"
      )
    } else {
      valueBox(
        value = if (YoY_growth > 0) paste0("+",round(YoY_growth, digits = 2), "%") else paste0(round(YoY_growth, digits = 2), "%"),
        subtitle = paste0(
          if (YoY_growth > 0) "Up" else if (YoY_growth == 0) "No change" else "Down",
          " from ", selected_year - 1
        ),
        icon = if (YoY_growth > 0) icon("arrow-up") else if (YoY_growth == 0) icon("minus") else icon("arrow-down"),
        color = "orange"
      )
    }
  })
  
  #WASTE DISPOSED PER CAPITA (TOTAL T-O WASTE / T-O TOTAL POPULATION = TONNES/PERSON)
  output$WastePerCapita <- renderValueBox({
    
    total_tonnes <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      summarise(total_tonnes = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
      pull(total_tonnes)
    
    total_pop <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      summarise(total_pop = sum(Population, na.rm = TRUE)) %>%
      pull(total_pop)
    
    if(total_pop == 0 || total_tonnes == 0){
      valueBox(
        value = icon("minus"),
        subtitle = paste0("No data for ", input$year),
        icon = icon("person"),
        color = "teal"
      )
    } else {
      per_capita_tonnes <- (total_tonnes / total_pop)
      per_capita_kg <- per_capita_tonnes * 1000
      
      valueBox(
        value = paste0(format(round(per_capita_kg), big.mark = ","), " kg/person"),
        subtitle = paste0("Waste disposed per capita for ", input$year),
        icon = icon("person"),
        color = "teal"
      )
    }
  })
  
  #Store selected region - used for REGIONAL WASTE MAP & HISTORICAL BAR CHART
  selectedRegion <- reactiveValues(Region = "Thompson Okanagan")
  
  #REGIONAL WASTE MAP------------------------------------------------------------------------------------------------
  output$MunicipalWasteMap <- renderLeaflet({

    df_municipal_waste_disposed_filtered <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      select(Regional_District, Disposal_Rate_kg, Population)

    df_regions_map <- df_regions %>%
      left_join(df_municipal_waste_disposed_filtered, by = "Regional_District")
    
    # Check whether selected year has any data
    has_data <- any(!is.na(df_regions_map$Disposal_Rate_kg))

    map <- leaflet() %>%
      addPolygons(
        data = df_bc,
        fill = FALSE,
        color = "#555555",
        weight = 2,
        opacity = 1
      )
      
      if (has_data){
        pal <- colorNumeric(
          palette = c( 
            "#A6D8D8",
            "#4A9A9A",
            "#266F73",
            "#004B55"   # high
          ),
          domain = df_regions_map$Disposal_Rate_kg,
          na.color = "transparent",
        )
        
        map <- map %>%
         addPolygons(
          data = df_regions_map,
          layerId = ~Regional_District,
          fillColor = ~pal(Disposal_Rate_kg),
          weight = 1.5,
          color = "white",
          fillOpacity = 0.6,
          label = ~Regional_District,
          popup = ~paste0(
            "<strong>Regional District:</strong> ",
            Regional_District, 
            "<br><strong>Year:</strong> ", 
            input$year,
            "<br><strong>Disposal Rate:</strong> ",
            Disposal_Rate_kg,
            " kg/person",
            "<br><strong>Population:</strong>",
            format(Population, big.mark = ",")
          )
        ) %>%      
         addPolygons(
            data = df_TO_boundary,
            fill = FALSE,
            color = "#D11B4A",
            weight = 2,
            opacity = 1
          ) %>%
          addLegend(
            position = "bottomleft",
            colors = "#D11B4A",
            labels = "Thompson Okanagan Tourism Region",
            opacity = 1
          )%>%
          addLegend(
            pal = pal,
            values = df_regions_map$Disposal_Rate_kg,
            title = "Disposal Rate<br>(kg/person)",
            position = "bottomleft",
        )
      } else {
        # Show a message when there is no data for the selected year
        map <- map %>%
          addControl(
            html = paste0(
              "<div style='
            background: white;
            padding: 10px 15px;
            border-radius: 5px;
            box-shadow: 0 1px 5px rgba(0,0,0,0.4);
            font-size: 14px;
          '>
            <strong>No data available</strong><br>
            No waste disposal data is available for ",
              input$year,
              ".
          </div>"
            ),
            position = "topleft"
          )
      }
    map
  })
  
  #REGIONAL DISPOSAL RATE COMPARED BAR CHART----------------------------------------------------------------------------
  output$DisposalRateBarPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_DisposalRateBarPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_disposed_TO_filtered <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      arrange(desc(Disposal_Rate_kg))  %>%
      mutate(
        Regional_District = factor(
          Regional_District,
          levels = rev(Regional_District)
        ))

    plot <- ggplot(df_disposed_TO_filtered, aes(y = Regional_District,
                                                x = Disposal_Rate_kg, 
                                                text = paste0(
                                                  "<b>", Regional_District, ",</b>",
                                                  "<br><b>", input$year, "</b>",
                                                  "<br><b>Waste Disposal Rate: </b><br>", scales::comma(Disposal_Rate_kg), " kg/person",
                                                  "<br><b>Population: </b>", scales::comma(Population)
                                                )))+
      
      geom_col(aes(fill = Regional_District == selectedRegion$Region), linewidth = 1.5)+
      scale_fill_manual(
        values = c("FALSE" = "#004B55", "TRUE" = "#D11B4A"),
        guide = "none"
      )+
      
      scale_x_continuous(
        breaks = if (is_narrow) scales::breaks_pretty(n = 4) else seq(0, 1200, by = 100),
        # labels = function(x) paste0(x / 1e6, "M"),
        expand = expansion(mult = c(0, 0.3))
      )+
      
      scale_y_discrete(
        labels = c(
          "North Okanagan" = "North<br>Okanagan",
          "Central Okanagan" = "Central<br>Okanagan",
          "Thompson-Nicola" = "Thompson<br>Nicola",
          "Okanagan-Similkameen" = "Okanagan<br>Similkameen",
          "Kootenay Boundary" = "Kootenay<br>Boundary",
          "Columbia-Shuswap" = "Columbia<br>Shuswap",
          "Fraser-Fort George" = "Fraser-Fort<br>George"
        ),
        expand = expansion(add = 0.2)
      )+
      
      labs(
        y = NULL,
        x = paste0(input$year, " Disposal Rate <br>kg/person")) +
      
      theme(
        axis.title = element_text(size = if (is_narrow) 12 else 18),
        axis.text = element_text(size = if (is_narrow) 8 else 12)
      )
    
    ggplotly(plot, tooltip = "text") %>%
      layout(
        margin = list(l = 0, r = 10, t = 10, b = 50),
        hoverlabel = list(
          bgcolor = "#F6BC1A",
          bordercolor = "#F6BC1A",
          font = list(
            color = "white",
            size = 13,
            family = "Arial"
          ),
          align = "left"
        )
      ) %>%
      config(displayModeBar = FALSE)
    
  })
 
  #REACTIVE EVENT FOR HISTORIC BAR CHART ------------------------------------------------- 
  observeEvent(input$MunicipalWasteMap_shape_click, {
    
    click <- input$MunicipalWasteMap_shape_click
    req(click$id)
    selectedRegion$Region <- click$id
  })
  
  Region_data <- reactive({  
    req(selectedRegion$Region)
    
    if (selectedRegion$Region == "Thompson Okanagan") {
      
      df_municipal_waste_disposed_TO %>%
        group_by(Year) %>%
        summarise(
          Population = sum(Population, na.rm = TRUE),
          Total_Disposed_Tonnes = sum(
            Total_Disposed_Tonnes,
            na.rm = TRUE
          ),
          Disposal_Rate_kg =
            (Total_Disposed_Tonnes * 1000) / Population,
          Regional_District = "Thompson Okanagan",
          .groups = "drop"
        )
      
    } else {
      df_municipal_waste_disposed_TO %>%
        filter(
          Regional_District == selectedRegion$Region
        )
    }
  })
  #HISTORIC BAR CHART 1990 TO MOST RECENT YEAR----------------------------------------
  output$HistoricalBarPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_HistoricalBarPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df <- Region_data()
    
    plot <- ggplot(df, 
             aes(x = Year, 
                 y = Disposal_Rate_kg,
                 text = paste0(
                   "<b>", Regional_District, ",</b>",
                   "<br><b>", Year, "</b>",
                   "<br><b>Waste Disposal Rate: </b><br>", scales::comma(Disposal_Rate_kg), " kg/person",
                   "<br><b>Population: </b>", scales::comma(Population)
                 ))) + 
        geom_bar(stat = "identity",
                 fill = "#76ACA9",
                 linewidth = 0.5) +
     
        scale_x_continuous(breaks = c(seq(1990, 2018, by = 4), 2021, 2024),
                           labels = c(seq(1990, 2018, by = 4), 2021, 2024),
                           expand = expansion(0.04)) +
     
        scale_y_continuous(expand = c(0,0), 
                           breaks = c(0, 250, 500, 750, 1000),
                           labels = c("0", "250", "500", "750", "1,000"),
                           limits = c(0, 1000)) +
     
        labs(
          x = NULL, 
          y = "Disposal Rate (kg/person)"
        ) +
        
        theme(legend.title = element_blank(),
              axis.title = element_text(size = if (is_narrow) 10 else 16),
              axis.text = element_text(size = if (is_narrow) 8 else 12),
              axis.text.x = element_text(angle = if (is_narrow) 60 else 30))
   
   ggplotly(plot, tooltip = "text") %>%
     layout(
       margin = list(l = 0, r = 10, t = 0, b = 50),
       hoverlabel = list(
         bgcolor = "#004B55",
         bordercolor = "#00363D",
         font = list(
           color = "white",
           size = 13,
           family = "Arial"
         ),
         align = "left"
       )
     ) %>%
     config(displayModeBar = FALSE)
  })
  
  #DYNAMIC UI BOX FOR HISTORIC CHART -----------------------------------------
  output$HistoricalBarPlotBox <- renderUI({
    
    req(selectedRegion$Region)
    
    df <- Region_data()
    
    box(
      title = paste0(
        "Disposal Rates for ",
        selectedRegion$Region,
        " (",
        min(df$Year, na.rm = TRUE),
        "-",
        max(df$Year, na.rm = TRUE),
        ")"
      ),
      p("Click a region on the map above to show disposal rate history for that region."),
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 12,
      
      plotlyOutput(
        "HistoricalBarPlot",
        height = 500
      )
    )
  })
  
  #REGIONAL WASTE TABLE------------------------------------------------------------------------
  output$RegionTable <- renderUI({
    
    df_municipal_waste_disposed_filtered <- df_municipal_waste_disposed_TO %>%
      filter(Year == input$year) %>%
      arrange(desc(Disposal_Rate_kg))
    
    if(is.na(sum(df_municipal_waste_disposed_filtered$Disposal_Rate_kg))){
      tags$h2(paste("No data available for ", input$year))
    } else {
      tonnes_per_person <- sum(df_municipal_waste_disposed_filtered$Total_Disposed_Tonnes) / sum(df_municipal_waste_disposed_filtered$Population)
      kg_per_person <- tonnes_per_person * 1000
      
      tags$table(
        class = "table table-striped table-sm",
        tags$thead(
          tags$tr(
            tags$th("Regional District"),
            tags$th("Population"),
            tags$th("Total Disposed Tons"),
            tags$th("Disposal Rate kg/person")
          )
        ),
        
        tags$tbody(
          lapply(seq_len(nrow(df_municipal_waste_disposed_filtered)), function(i) {
            
            tags$tr(
              tags$td(df_municipal_waste_disposed_filtered$Regional_District[i]),
              tags$td(format(df_municipal_waste_disposed_filtered$Population[i], big.mark = ",")),
              tags$td(format(df_municipal_waste_disposed_filtered$Total_Disposed_Tonnes[i], big.mark = ",")),
              tags$td(df_municipal_waste_disposed_filtered$Disposal_Rate_kg[i])
            )
            
            
          })
        ),
        
        tags$tfoot(
          style = "font-weight: bold;",
          tags$tr(
            tags$td("Total"),
            tags$td(format(sum(df_municipal_waste_disposed_filtered$Population, na.rm = TRUE), big.mark = ",")),
            tags$td(format(sum(df_municipal_waste_disposed_filtered$Total_Disposed_Tonnes, na.rm = TRUE), big.mark = ",")),
            tags$td(round(kg_per_person))
          )
        )
      )
    }
  })
  
  #BOX UI OUTPUT FOR DYMANIC YEAR IN TITLE FOR DATA TABLE -----------------------------------------------------------------------------------------------------
  output$RegionTableBox <- renderUI({
    box(
      title = paste0("Data - ", input$year),
      solidHeader = TRUE,
      collapsible = TRUE,
      width = 6,
      htmlOutput("RegionTable")
    )
  })

  #ORGANIC WASTE PAGE ===========================================================================================
  
  #VALUE BOX FOR NUMBER OF ACTIVE COMPOSTING FACILITIES
  output$NumActive <- renderValueBox({
    
    valueBox(
      value = paste(nrow(df_organic_waste_bc)),
      subtitle = "Number of compost production facilities",
      icon = icon("warehouse"),
      color = "orange"
    )
  })
  
  #VALUE BOX FOR PECENT OF FACILITIES ACCEPTING FOOD WASTE
  output$PrecentFoodWaste <- renderValueBox({
    
    foodWaste_count <- df_organic_waste_bc %>%
      filter(`Food Waste` == "Yes")
    
    precent_food <- (nrow(foodWaste_count)/nrow(df_organic_waste_bc))*100
    
    valueBox(
      value = paste0(round(precent_food, digits = 2), "%"),
      subtitle = "Precent of facilities accepting food waste.",
      icon = icon("carrot"),
      color = "teal"
    )
  })
  
  #VALUE BOX FOR PECENT OF FACILITIES ACCEPTING BREWERY WASTE
  output$PrecentBreweryWaste <- renderValueBox({
    
    breweryWaste_count <- df_organic_waste_bc %>%
      filter(`Brewery Waste/Wine Waste` == "Yes")
    
    precent_brewery <- (nrow(breweryWaste_count)/nrow(df_organic_waste_bc))*100
    
    valueBox(
      value = paste0(round(precent_brewery, digits = 2), "%"),
      subtitle = "Precent of facilities accepting brewery & wine waste.",
      icon = icon("wine-bottle"),
      color = "orange"
    )
  })
  
  #STORE SELECTED OPERATION
  selectedAuthNum <- reactiveValues(AuthNum = NULL)
  
  #MAP OF ACTIVE COMPOSTING OPERATIONS IN THE REGION -----------------------------------------------------------------------------------------------------
  output$OrganicWasteMap <- renderLeaflet({
    
    operation_colors <- c(
      "Compost Production Facility" = "#004B55",
      "Thompson Okanagan Tourism Region" = "#D11B4A"
    )

    
    m_base <- leaflet(data = df_TO_boundary)  
    m_tiles <- addTiles(m_base)
    m_bound <- addPolygons(m_tiles,
      data = df_TO_boundary,
      fill = FALSE,
      color = "#D11B4A",
      weight = 2,
      opacity = 1
    ) 
      
    m_markers <- addCircleMarkers(m_bound,
                                  data = df_organic_waste_bc,
                                  lng = ~Longitude,
                                  lat = ~Latitude,
                                  layerId = ~`Authorization Number`,
                                  radius = 8,
                                  color = "#000",
                                  weight = 1,
                                  fillColor = ~unname(operation_colors[`Operation Type`]),
                                  stroke = TRUE,
                                  fillOpacity = 0.9,
                                  label = ~paste0(`Facility Location`),
                                  popup = ~paste0("<b>",`Regulated Party`,"</b><br>",
                                                  "<b>Type of compost produced: </b>", `Type of Compost Produced`, "<br>"
                                                  )
      
                                  ) %>%
      addLegend(
        position = "bottomright",
        colors = unname(operation_colors),
        labels = names(operation_colors),
        title = "",
        opacity = 1
      )
    
    setView(m_markers, lng = -118.196086, lat = 50.998195, zoom = 6)
    
  })
  
  observeEvent(input$OrganicWasteMap_marker_click, {
    click <- input$OrganicWasteMap_marker_click
    req(click$id)
    selectedAuthNum$AuthNum <- click$id
    
  })

  Operation_data <- reactive({  
    if (is.null(selectedAuthNum$AuthNum)) {
      return(data.frame())
    }

    df_organic_waste_bc %>% filter(`Authorization Number` == selectedAuthNum$AuthNum)
  })
  
  #ORGANIC MATERIAL ACCEPTED TABLE
  output$AcceptedTable <- renderUI({
    df <- Operation_data()
    
    df_selected <- df %>% 
      select(Manure, `Untreated and Unprocessed Wood Residuals`, `Domestic Septic Tank Sludge`, 
             `Plant Matter Derived From Processing Plants`, `Yard Waste`, `Fish Wastes`, Whey, 
             `Animal Bedding`, Biosolids, `Hatchery Waste`, `Milk Processing Waste`, `Poultry Carcasses`,
             `Brewery Waste/Wine Waste`, `Food Waste`, `Red Meat Waste`) %>%
      mutate(
        `Red Meat Waste` = if_else(`Red Meat Waste`, "Yes", "No")
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = "Material",
        values_to = "Accepted"
      )
    
    tags$table(
      class = "table table-sm",
      tags$thead(
        tags$tr(
          tags$th("Types of organic matter accepted")
        )
      ),
      
      tags$tbody(
        lapply(seq_len(nrow(df_selected)), function(i) {
          tags$tr(
            if(df_selected$Accepted[i] == "Yes") {
              tags$td(df_selected$Material[i])
            }
          )
        })
      )
    )
  })
  
  #ORGANIC MATERIAL NO ACCEPTED TABLE
  output$NotAcceptedTable <- renderUI({
    df <- Operation_data()
    
    df_selected <- df %>% 
      select(Manure, `Untreated and Unprocessed Wood Residuals`, `Domestic Septic Tank Sludge`, 
             `Plant Matter Derived From Processing Plants`, `Yard Waste`, `Fish Wastes`, Whey, 
             `Animal Bedding`, Biosolids, `Hatchery Waste`, `Milk Processing Waste`, `Poultry Carcasses`,
             `Brewery Waste/Wine Waste`, `Food Waste`, `Red Meat Waste`) %>%
      mutate(
        `Red Meat Waste` = if_else(`Red Meat Waste`, "Yes", "No")
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = "Material",
        values_to = "Accepted"
      )
    
    tags$table(
      class = "table table-sm",
      tags$thead(
        tags$tr(
          tags$th("Types of organic matter not accepted")
        )
      ),
      
      tags$tbody(
        lapply(seq_len(nrow(df_selected)), function(i) {
          
          tags$tr(
            
            if(df_selected$Accepted[i] == "No") {
              tags$td(df_selected$Material[i])
            } 
          )
        })
      )
    )
  })
  
  #ORGANIC MATTER ACCEPTED BAR CHART
  output$OrganicsAcceptedPlot <- renderPlotly({
    
    plot_width <- session$clientData$output_OrganicsAcceptedPlot_width
    is_narrow <- !is.null(plot_width) && plot_width < 600
    
    df_materials <- df_organic_waste_bc %>% 
      select(Manure, `Untreated and Unprocessed Wood Residuals`, `Domestic Septic Tank Sludge`, 
             `Plant Matter Derived From Processing Plants`, `Yard Waste`, `Fish Wastes`, Whey, 
             `Animal Bedding`, Biosolids, `Hatchery Waste`, `Milk Processing Waste`, `Poultry Carcasses`,
             `Brewery Waste/Wine Waste`, `Food Waste`, `Red Meat Waste`) %>%
      mutate(
        `Red Meat Waste` = if_else(`Red Meat Waste`, "Yes", "No")
      ) %>%
      rename(
        "Plant Matter" = `Plant Matter Derived From Processing Plants`,
        "Wood Residuals" = `Untreated and Unprocessed Wood Residuals`,
        "Brewery/Wine Waste" = `Brewery Waste/Wine Waste`,
        "Septic Tank Sludge" = `Domestic Septic Tank Sludge`
      ) %>%
      pivot_longer(
        cols = everything(),
        names_to = "Material",
        values_to = "Accepted"
      ) %>%
      mutate(
        Type = if_else(Accepted == "Yes", 1, 0)
      ) %>%
      group_by(Material) %>%
      summarise(
        Count = sum(Type, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      mutate(
        Material = reorder(Material, Count)
      )

    plot <- ggplot(df_materials, aes(y = Material,
                                     x = Count, 
                                     text = paste0("<b>", Count, " out of ", nrow(df_organic_waste_bc), " facilities</b>")))+
      
      geom_col(fill = "#76ACA9", linewidth = 1.5) +
      
      scale_x_continuous(
        breaks = if (is_narrow) scales::breaks_pretty(n = 4) else seq(0, nrow(df_organic_waste_bc), by = 5),
        expand = expansion(mult = c(0, 0.3))
      )+
      
      labs(
        y = "",
        x = "Number of Facilities") +
      
      theme(
        axis.title = element_text(size = if (is_narrow) 10 else 16),
        axis.text = element_text(size = if (is_narrow) 8 else 12),
      )
    
    ggplotly(plot, tooltip = "text") %>%
      layout(
        margin = list(l = 0, r = 10, t = 0, b = 50),
        hoverlabel = list(
          bgcolor = "#004B55",
          bordercolor = "#00363D",
          font = list(
            color = "white",
            size = 13,
            family = "Arial"
          ),
          align = "left"
        )
      ) %>%
      config(displayModeBar = FALSE)
  })
  
  #DYNAMIC TABLE BOX FOR ORGANIC MATTER ACCEPTED
  output$DynamicTableBox <- renderUI({
    
    df <- Operation_data()
    if(nrow(df) == 0){
        h5("Select a compost facility on the map to view what organic matter is accepted.")
    } else {
      box(
        title = "Facility Details",
        solidHeader = TRUE,
        collapsible = TRUE,
        width = 12,
        
        fluidRow(
          column(
            width = 6,
            p(HTML(paste0("<strong>Location:</strong> ", df$`Facility Location`))),
            p(HTML(paste0("<strong>Regulated Party:</strong> ", df$`Regulated Party`)))
          ),
          
          column(
            width = 6,
            p(HTML(paste0("<strong>Authorization Number:</strong> ", df$`Authorization Number`))),
            p(HTML(paste0("<strong>Facility Capacity (t/y):</strong> ", df$`Facility Design Capacity (t/y)`)))
          )
        ),
        br(),
        fluidRow(
          column(
            width = 6,
            htmlOutput("AcceptedTable")
          ),
          column(
            width = 6,
            htmlOutput("NotAcceptedTable")
          )
        )
      )
    }
  })
  
  #CLICKABLE LINKS ON HOME PAGE
  observeEvent(input$disposal_rates_link, {
    updateTabItems(session, "tabs", "disposal_rates")
  })
  
  observeEvent(input$organic_link, {
    updateTabItems(session, "tabs", "organic")
  })
}
