#' Transect Sample
#'
#' This is a wrapper for st_line_sample.  The PEM transect lines are used to generate a minimum of one point per line segment. Additional sample points are added at a minimum distance of 5 metres.
#'
#' _Note: current version does not include the raster method._
#'
#' @param lines is a sf _LINES_ object.
#' @param mdist Optional with a default of 5m
#' @keywords points, transects, samples, sampling
#' export

transect_sample <- function(lines, mdist = 5) {
  for (i in 1:nrow(lines)) {
    # i <- 1
    L <- lines[i,]
    print(paste(L$TID, L$id, st_length(L)))

    sample <- st_line_sample(L,
                             density = 1/mdist) %>%  ## 1 sample every 5m
        st_cast(., "POINT") %>% ## convert from point to multipoint.
        st_sfc(.) %>% st_sf(.)  ## generate geom column and convert to sf object

    sample <- st_join(sample, st_buffer(L, 5))

    ## if first time create samples else append
    if (i == 1) {samples <- sample} else {samples <- rbind(samples, sample)}
  }
  return(samples)
}
