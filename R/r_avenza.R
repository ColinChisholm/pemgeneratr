#' r_avenza
#'
#' Loads data colleted in the ipad app _Avenza Maps_ arranges it by
#' time stamp and returns an organized sf data frame.
#' Requires that Avenza data is exported in GPX and SHP formats.
#' This is done as the GPX data provides an detailed timestamp.
#' Where in the SHP data provides easier to manage attribute data.
#'
#' @param shp The shapefile data loaded as an _sf_ object.
#' @param gpx The gpx data loaded as an _sf_ object.
#' @param crs NOT IMPLEMENTED / PENDING The projection string or epsg code for the output data to transformed to.
#' @param att NOT IMPLEMENTED / PENDING ... Additional attributes or data columns you wish to keep.  For example, custom attributes fields generated in Avenza.  By default, the point id, name, time, Photos, and desc fields are kept.
#' @keywords Avenza, GPS, import
#' @export
#' @examples
#' gpsData <- r_avenza(shpData, gpxData,
#'                     crs = 3157,
#'                     attributes = c("")


r_avenza <- function(shp, gpx) {
  library(magrittr)
  gpx <- as.data.frame(dplyr::select(time)) ## Grab timestamp from gpx data

  ## join data and return relavent columns
  shp <- dplyr::bind_cols() %>% arrange(time) %>% ## bind
    mutate(id = row_number()) %>%
    dplyr::select(id, name, time, Photos, desc)

  return(shp)
}
