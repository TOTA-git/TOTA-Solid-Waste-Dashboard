# Data refresh job.
#
# Fetches every externally-sourced dataset the app depends on and writes
# each one to data/cache/. Each dataset is fetched and written
# independently: if one source fails (site down, API change, network
# blip), that dataset's existing cache file is left untouched and the
# rest of the refresh continues. global.R only ever reads from
# data/cache/, so the app always has the most recent successful pull
# of each dataset, even if today's refresh partially failed.
#
# Run manually with:
#   Rscript data_refresh.R
#
# To run this once a day.
# (e.g.GitHub Actions)

library(httr)
library(jsonlite)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(sf)
library(geojsonsf)
library(rvest)
library(chromote)

source("R/data_helpers.R")

clear_refresh_log()

refresh_dataset <- function(name, fetch, write) {
  message("Refreshing ", name, "...")
  tryCatch(
    {
      value <- fetch()
      write(value)
      log_refresh(name, "success", n_rows = NROW(value))
      message("  OK (", NROW(value), " rows)")
      TRUE
    },
    error = function(e) {
      log_refresh(name, "failure", message = conditionMessage(e))
      message("  FAILED - keeping previous cache: ", conditionMessage(e))
      FALSE
    }
  )
}


#MUNICIPAL SOILD WASTE DISPOSED IN BC ---------------------------------------------------------------------------
refresh_dataset(
  "municipal_waste_disposed",
  function() {
    read_csv("https://catalogue.data.gov.bc.ca/dataset/d21ed158-0ac7-4afd-a03b-ce22df0096bc/resource/d2648733-e484-40f2-b589-48192c16686b/download/bc_municipal_solid_waste_disposal.csv",
      show_col_types = FALSE
    )
  },
  function(df) atomic_write_csv(df, file.path(CACHE_DIR, "municipal_waste_disposed.csv"))
)

#ORGANIC WASTE BC ------------------------------------------------------------------------------
refresh_dataset(
  "organic_waste_bc",
  function(){
    data <- fromJSON("https://organicsinfo.gov.bc.ca/api/omrr", simplifyVector = TRUE)
    
    df <- as.data.frame(data$omrrData)
    
    omrr_sf <- st_as_sf(
      df,
      coords = c("Longitude", "Latitude"),
      crs = 4326,
      remove = FALSE
    )
    
    region <- st_read("data/thompson_okanagan_boundary.geojson", quiet = TRUE)
    
    region <- st_transform(region, st_crs(omrr_sf))
    
    # Keep only OMRR locations inside the tourism region
    omrr_sf <- st_filter(
      omrr_sf,
      region,
      .predicate = st_within
    )
    
    # Remove geometry before saving CSV
    st_drop_geometry(omrr_sf)
    
    omrr_sf <- omrr_sf %>%
      filter_out(`Authorization Status` == "Inactive") %>%
      filter(`Operation Type` == "Compost Production Facility")

  },
  function(df) atomic_write_csv(df, file.path(CACHE_DIR, "organic_waste_bc.csv"))
)

#ORGANIC WASTE BC LAST MODIFIED -------------------------------------------------------------
refresh_dataset(
  "organic_waste_lastModified",
  function(){
    data <- fromJSON("https://organicsinfo.gov.bc.ca/api/omrr")
    as.data.frame(data$lastModified)
  },
  function(df) atomic_write_csv(df, file.path(CACHE_DIR, "organic_waste_lastModified.csv"))
)

message("Data refresh complete. See ", file.path(CACHE_DIR, "refresh_log.csv"), " for a run history.")