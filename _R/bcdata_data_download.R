## A script to download bcdata based on a user defined area of interest.
## Get essential basemap layers, and numerous forest management layers.
##
## Initiated by C. Chisholm on June 16, 2020
## Version 1.1 completed July 17, 2020

## Outline ###############################
## 1. Set up parameters 
## 2. Define an area of interest. Options:
##    - interactive via `draw()` function
##    - load and area of interest polygon
## 3. Query BCdata for layers that you want -- numerous default layers have been set up.
## 4. Collect and Export desired data files.  
##    I have set this up as a function `collect_all()`  and added `collect_custom()`
##    All layers, with data are saved in geojson format (other formats failed to save.)
## Appendix: Exploring data



## Load Libraries ----------------
library(mapview) ## webmap viewer 
library(leaflet) ## additional viewer
library(mapedit) ## allows creation of features over webmap
## https://www.r-spatial.org/r/2017/01/30/mapedit_intro.html
# install.packages("mapedit")
library(sf)      ## all things spatial
library(bcdata)  ## tools for accessing bcdata:  http://data.gov.bc.ca




## 1. Set Parameters -------------

# setwd("e:/workspace/2020/SGreen_NREM303/") ## commented out -- 
outDir <- "bcdata/"         ## subfolder to save data to 
FileName <- "Basemap"       ## Filename prefix for basemap layers
ForestLayers   <- "Forest"  ## Filename prefix for forestry/tenure layers 
CustomName <- "Other"            ## Filename prefix for custom layers set
## make ourDir if needed 
if (!dir.exists(outDir)) {dir.create(outDir)}


## 2. Define AOI ------------
## * Function to capture an area of interest --------
draw <- function(xmin = -139, ymin = 49, xmax = -114, ymax = 60,
                 basemap = "GeoportailFrance.orthos") { ##Other Providers: "CartoDB.Positron", "Esri.WorldImagery", "Esri.DeLorme"
  d <- leaflet() %>%
    fitBounds(xmin, ymin,  xmax, ymax, options = list()) %>%     ## set to extent of BC
    addProviderTiles(basemap) %>%         
    editMap()
  return(d$finished)
}

## * Call draw() -------------
aoi <- draw() %>% st_transform(., 3005) ## BC Albers 3005; convert to UTM 3157
# aoi$area <- st_area(aoi) %>% units::set_units("ha")  ## calc area as hectares

## * Or load aoi -------------

# aoi <- st_read("LT_researchforest/proposed_researchforest.shp") %>% st_transform(., 3005)
# aoi <- st_read("d:/GIS/ALRF/_MostRequested_/ALRF Boundary/ALRF_Boundary_BGC.gpkg") %>% 
  # st_transform(., 3005)
# # st_is_valid(aoi)
# 
# ## sometimes shapefiles provided are invalid.  -- this attempts to repair them
# if (!st_is_valid(aoi)) {
#   aoi <- st_buffer(aoi,0)
#   print("Attempting to repair invalid geometry")
#   print(paste("Geometry is valid:", st_is_valid(aoi)))
# }
# 
# ## In this case I want a buffered extent of the provided shapefile
# 
# aoi <- st_bbox(aoi) %>% st_as_sfc(.) %>% 
#   st_buffer(., 2000) %>% 
#   st_bbox(.) %>% st_as_sfc(.) ## to extent of the buffer area (no rounded corners)

## display aoi in mapview -- confirms creation / location
aoi
mapview(aoi)


## 3. Query BC data -----------------
## sample code for how to search the bcdata for layers
pot <- bcdc_search("Forest Service Roads", n = 500)
names(pot)# %>% sort()


## * lists of data to get ----------
## names collected from the search above

## bcdata names
Basemap <- c("WHSE_BASEMAPPING.GBA_RAILWAY_TRACKS_SP",
             "digital-road-atlas-dra-master-partially-attributed-roads",
             "freshwater-atlas-coastlines",
             "freshwater-atlas-lakes",
             "freshwater-atlas-islands",
             "freshwater-atlas-rivers",
             "freshwater-atlas-stream-network",
             "freshwater-atlas-wetlands"
             )

## Shortnames -- used in naming output files
Basemap_dict <- c("Rails",
                  "Roads",
                  "Water-Coastline",
                  "Water-Lakes",
                  "Water-Islands",
                  "Water-Rivers",
                  "Water-Streams",
                  "Water-Wetlands")

## Forest / tenure / landuse datasets 
forest <- c(
            # "WHSE_FOREST_VEGETATION.VEG_COMP_LAYER",  ## vri -- not downloadable via bcdata
            "results-forest-cover-reserve",
            "results-forest-cover-inventory",
            "results-forest-cover-silviculture",
            "results-openings-svw",
            "results-activity-treatment-units",
            "bc-parks-ecological-reserves-and-protected-areas", 
            "forest-road-segment-tenure",
            "923c5330-c798-4276-82c1-705000c5caac",  ### Mineral Tenures
            "WHSE_MINERAL_TENURE.MTA_CROWN_GRANT_MIN_CLAIM_SVW", ## Mineral Claims
            "tantalis-crown-tenures", ## Other uses 
            "WHSE_ADMIN_BOUNDARIES.FADM_TFL_ALL_SP", ## TFLs
            "WHSE_FOREST_TENURE.FTEN_MANAGED_LICENCE_POLY_SVW", ## Woodlots and Community Forests
            "WHSE_FOREST_TENURE.FTEN_SPEC_USE_PERMIT_POLY_SVW", ## SUPs
            "WHSE_FOREST_TENURE.FTEN_HARVEST_AUTH_POLY_SVW",    ## Harvest Authorities (e.g. Cutting Permits -- PEnding, Active, Retired)
            "WHSE_WILDLIFE_MANAGEMENT.WCP_UNGULATE_WINTER_RANGE_SP" ## Ungulate winter range
            )

## Forest / tenure / landuse -- shortname.  Used for output filenames
forest_dict <- c(
              # "vri",
              "RESULTS-wtr",
              "RESULTS-inv",
              "RESULTS-silv",
              "RESULTS-openings",
              "RESULTS-act",
              "Parks",
              "Road-Tenure",
              "Mineral-Tenure",
              "Mineral-Claims",
              "Other-Tenures",
              "TFLs",
              "CommunityF-Woodlots",
              "SUPs",
              "Harvest", 
              "Ungulate-Winter-Range")


custom <- c("WHSE_FOREST_TENURE.FTEN_ROAD_SECTION_LINES_SVW") ## Forest Tenure Road Section Lines
##Note: this road layer requires an API key for download ... get via databc portal instead.            

custom_dict <- c("ForestRoadsSections")


### 4. Collect & Save all the data ------------------
collect_all <- function(aoi = aoi) { ## wrapped the collection steps in a function 
  
  st_write(aoi, dsn = paste0(outDir, FileName,"_aoi", ".geojson"),
           layer = "aoi",
           delete_dsn = TRUE)
  
  ## * Collect/Save Basemap Layers --------------
  for (i in 1:length(Basemap)) {
  
    # i <- 3
    print(Basemap[i])
  
    ## collect the data
    dat <- bcdc_query_geodata(Basemap[i], crs = 3005) %>%
      bcdata::filter(INTERSECTS(aoi)) %>%
      collect() %>%
      {if(nrow(.) > 0) st_intersection(., aoi) else .}
  
    if (nrow(dat) == 0) { 
      print(paste0("No ", Basemap_dict[i], " features in the area of interest."))} else{
      st_write(dat,
             dsn = paste0(outDir, FileName, "_", Basemap_dict[i], ".geojson"),
             layer = Basemap_dict[i], 
             delete_dsn = TRUE)
      }
  }
  
  
  ## * Collect/Save Forest Layers ------------
  for (i in 1:length(forest)) {
  # for (i in 11:14) {
    
    # i <- 11
    print(forest[i])
    
    ## collect the data
    dat <- bcdc_query_geodata(forest[i], crs = 3005) %>%
      bcdata::filter(INTERSECTS(aoi)) %>%
      collect() %>%
      {if(nrow(.) > 0) st_intersection(., aoi) else .}
    
    if (nrow(dat) == 0) { 
      print(paste0("No ", forest_dict[i], " features in the area of interest."))} else{
        st_write(dat,
                 dsn = paste0(outDir, ForestLayers, "_", forest_dict[i], ".geojson"),
                 layer = forest_dict[i], 
                 delete_dsn = TRUE)
      }
  }
}
collect_all(aoi = aoi)


collect_custom <- function(aoi) {
  for (i in 1:length(custom)) {
    # for (i in 11:14) {
    
    # i <- 11
    print(custom[i])
    
    ## collect the data
    dat <- bcdc_query_geodata(custom[i], crs = 3005) %>%
      bcdata::filter(INTERSECTS(aoi)) %>%
      collect() %>%
      {if(nrow(.) > 0) st_intersection(., aoi) else .}
    
    if (nrow(dat) == 0) { 
      print(paste0("No ", custom_dict[i], " features in the area of interest."))} else{
        st_write(dat,
                 dsn = paste0(outDir, CustomName, "_", custom_dict[i], ".geojson"),
                 layer = custom_dict[i], 
                 delete_dsn = TRUE)
      }
  }
}
collect_custom(aoi = aoi)


### Appendix: Exploring data -------------
## Download a single layer and explore it
## Sample below examines RESULTS activities for chemical brushing
i <- 5
forest_dict[i]
dat <- bcdc_query_geodata(forest[i], crs = 3005) %>%
  bcdata::filter(INTERSECTS(aoi)) %>%
  collect() %>%
  {if(nrow(.) > 0) st_intersection(., aoi) else .}


brushing <- dat %>% dplyr::filter(SILV_BASE_CODE == "BR")
recent <- brushing %>% dplyr::filter(ATU_COMPLETION_DATE >= as.Date("2010-01-01"))
recent_chemical <- recent %>% dplyr::filter(SILV_TECHNIQUE_CODE %in% c("CG", "CA"))

st_write(recent_chemical, "./bcdata/recent-chem.geojson")

mapview(recent_chemical)

