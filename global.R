library(ggplot2)
library(readr)
library(dplyr)
library(shiny)
library(bslib)
library(shinydashboard)
library(fresh)
library(bcmaps)
library(sf)
library(leaflet)
library(httr)
library(jsonlite)
library(plotly)
library(tidyr)

source("R/data_helpers.R")

# All externally-sourced data below is read from data/cache/, which is
# populated by data_refresh.R on a schedule. The app itself never
# scrapes or calls an external API directly at startup - if a scheduled
# refresh fails for a dataset, its cache file is left untouched, so the
# app keeps running on the last successful pull (see
# data/cache/refresh_log.csv for a history of refresh attempts).

#MUNICIPAL WASTE DISPOSAL -------------------------------------------------
#Frequency of Resource Update: Annually by the Ministry of Environment and Parks
#Beginning Date 1990-01-01
df_municipal_waste_disposed <- read_cache_csv("municipal_waste_disposed")

#Filter Thompson Okanagan Regions
selected_districts <- c(
  "Central Okanagan",
  "North Okanagan",
  "Okanagan-Similkameen",
  "Thompson-Nicola",
  "Columbia-Shuswap",
  "Kootenay Boundary",
  "Fraser-Fort George"
)

df_municipal_waste_disposed_TO <- df_municipal_waste_disposed %>%
  filter(Regional_District %in% selected_districts)

#BC TOTAL WASTE DISPOSED FOR MOST RECENT YEAR
BC_total_recent <- df_municipal_waste_disposed %>%
  filter(Year == max(df_municipal_waste_disposed$Year)) %>%
  summarise(BC_total = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
  pull(BC_total)

#THOMPSON OKANAGAN TOTAL WASTE DISPOSED FOR RECENT YEAR
TO_total_recent <- df_municipal_waste_disposed_TO %>%
  filter(Year == max(df_municipal_waste_disposed_TO$Year)) %>%
  summarise(TO_total = sum(Total_Disposed_Tonnes, na.rm = TRUE)) %>%
  pull(TO_total)

#LOAD REGIONAL DISTRICTS GEOJSON FOR MUNICIPAL WASTE DISPOSAL MAP
df_regions <- st_read("data/regional_districts.geojson", quiet = TRUE)

#LOAD BC BOUNDRY GEOJSON
df_bc <- st_read("data/bc_boundary.geojson", quiet = TRUE)

#ORGANIC WASTE FOR BC
df_organic_waste_bc <- read_cache_csv("organic_waste_bc")

#ORGANIC WASTE DATA LAST MODIFIED
df_OW_lastModified <- read_cache_csv("organic_waste_lastModified")

#THOMPSON OKANAGAN BOUNDRY
df_TO_boundary <- st_read("data/thompson_okanagan_boundary.geojson")
