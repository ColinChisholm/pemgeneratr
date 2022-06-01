#' Erase Overlapping area of a polygon
#'
#' Analogous to QGIS' clip tool.  This function is taken from sf documentation.
#' Layers should be of the same class and projection
#'
#' z = x - y  -- where z is the resulting polygon
#'
#'
#' @param x an sf layer.  This is the layer that you would like to remove from.
#' @param y An sf polygon layer.  This area that will be removed from polygon x.  Obviously only areas that are overlapping will be removed
#' @keywords erase, clip, remove area
#' @export
#' @example
#' ... sorry pending -- see sf documentation for st_difference()

st_erase <- function(x, y) {
  st_difference(x, st_union(st_combine(y)))
  }

