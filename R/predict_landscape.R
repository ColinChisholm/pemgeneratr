#' Predict Landscape
#'
#' Takes a mlr model object and associated covariate rasters to generate a thematic map.
#' In order to process the landscape level prediction the input co-variated are tiled
#' and then mosaic'd together at the end.
#'
#' @param model A `mlr` model object
#' @param cov   A list of raster files.  These will be loaded as a `stars` object
#' @param tilesize Specify the number of pixels in the `x` and `y` directions for the tiles to be generated.  If your computer is mememory limited use a smaller tile (e.g. 500).
#' @param name Filename to of the final dataset
#' @param outDir directory for the output file.
#' @keywords predict, landscape
#' @export
#' predict_landscape(model = my_mlr_model,  ## an mlr model
#'                   cov = cov_list,        ## list of rasters -- must have the same names
#'                                          ## used to make the mlr model
#'                   tilesize = 1000,       ## tiles will be generated 1000 x 1000 px
#'                   name = "SiteSeries"    ## name of the output file
#'                   ourDir = "e:/output"   ## output directory
#'                   )

predict_landscape <- function(model,
                              cov,
                              tilesize = 500,
                              name = "predicted",
                              ourDir = "./predicted") {


## load covariates ------------


## update cov names -----------



## create tiles ---------------




## begin loop through tiles -----

  ## * load tile area---------


  ## * update names ---------


  ## * convert tile to dataframe ---------


  ## * predict ---------


  ## * geo-link predict values ---------


  ## * rasterize ---------


  ## * save tile ---------

  ## END LOOP



## Mosaic Tiles ---------------

}
