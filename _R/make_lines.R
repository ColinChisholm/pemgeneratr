#' make_lines()
#'
#' Converts GPS data/ waypoints to line features.  Attribute data is maintained.
#' Currently, this function generates points to transect by converting the _POINT_
#' feature data to LINES sf features.
#' A placeholder has been made to generate transect lines via the transect method created by M. Coghill.
#'
#' @param GPSPoints is a _simple features_ POINT object.
#'        Minimum attributes in this file include fields named _'id'_ and _'time'_.
#'        Waypoints will be sorted by these two entries.
#' @param Transects is the original planned transect simple feature.
#'        The _'id'_ attribute in this feature will be used to group points by their transect id.
#'        This transect id will be named 'TID' in the output data.
#' @param method Multiple methods to be made available:
#' - _pts2lines_ takes a sf POINT object and converts it to lines.
#' _This is currently the only function available
#' - _tracklog_ uses the tracklog and the sample points to generate the lines. _Not implemented yet_.
#' @param tBuffer is optional with a default of 20m.  This is the buffer distance to place around the transect.  Waypoints outside this distance will not be considered.
#' @param PROJ is an optional the epsg projection code with a default of BC Albers (3005).  Data imported will be transfored to this projection and final data will be exported in this projection.
#' @keywords points, lines, convertion
#' @export
#' @examples
#' ## Convert GPS waypoints to line features (i.e. transect data)
#' transects <- convert_pts2lines(gpsData, PlannedTransects)

make_lines <- function(GPSPoints, Transects, method = "pts2lines", tBuffer = 20, PROJ = 3005) {


  if (method == "pts2lines") {
    ## Transects
    planT <- Transects %>%
      rename(TID = id)  %>% ## rename the id to not conflict with the GPS id field
      st_buffer(.,tBuffer) %>% dplyr::select(TID)

    ## Spatial join attributes
    GPSPoints <- st_join(gpsData, planT)

    ## TESTING
    # PROJ <- 26910
    # GPSPoints <- gpsData #%>% dplyr::select(name, time)


    ## f(n) start
    ## ADD TRANSECT ID -- and the arrange TID, time

    GPSPoints <- GPSPoints %>% arrange(TID, time) %>%
      rowid_to_column("ID") %>% # ID is needed table manipulation below
      st_transform(PROJ)

    ## convert GPSPoints to a table for manipulation
    GPSPoints <- cbind(GPSPoints, st_coordinates(GPSPoints)) %>%
      st_zm %>% as.data.frame()

    ## this solves issue where geom is named 'geometry' other times 'geom'
    if("geom" %in% names(GPSPoints)) {
      GPSPoints <- GPSPoints %>% rename(geometry = geom)}

    ## Define the Line Start and End Coordinates
    lines <- GPSPoints %>%
      mutate(Xend = lead(X),
             Yend = lead(Y)) %>%  # collect the coordinates of the next point
      filter(!is.na(Yend)) #%>% # drops the last row (start point with no end)
    # dplyr::select(-geometry)

    ## Use data.table with sf to create the line geometry
    dt <- data.table::as.data.table(lines)
    sf <- dt[,
             {
               geometry <- sf::st_linestring(x = matrix(c(X, Xend, Y, Yend), ncol = 2))
               geometry <- sf::st_sfc(geometry)
               geometry <- sf::st_sf(geometry = geometry)
             }
             , by = ID
             ]

    ## Replace the geometry
    lines$geometry <- sf$geometry

    ## Declare as a simple feature
    lines <- st_sf(lines)
    st_crs(lines) <- PROJ


    ## Need to remove excess lines -- currently there are lines that run between the plots
    lines$within <- as.logical(st_within(lines, planT))
    lines <- lines[!is.na(lines$within == TRUE),]  ## removes lines not contained in Transect area


    ## There are a few invalid geometries
    lines$valid <- as.logical(st_is_valid(lines))
    lines <- lines[lines$valid == TRUE,]  ## removes lines not contained in Transect area

    lines <- lines %>% dplyr::select(TID, id, name, time, SiteSeries:Confidence)

    return(lines)

  } else {
  ## Begin transect method ----------------------------------------------------
  ## ADD MC's code here
    if (method == "tracklog") {
      print("Not built yet")
      print("Copy in MC's code")
    }
  }
}
