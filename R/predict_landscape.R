#' Predict Landscape
#'
#' Takes a mlr model object and associated covariate rasters to generate a thematic map.
#' In order to process the landscape level prediction the input co-variated are tiled
#' and then mosaic'd together at the end.
#'
#' **Action** _is there a bug in tilemaker or with stars causing a xy offset error.
#' Solution is currently a hack.  See `load tile area`.
#'
#' @param model A `mlr` model object
#' @param cov   A list of raster files.  These will be loaded as a `stars` object
#' @param tilesize Specify the number of pixels in the `x` and `y` directions for the tiles to be generated.  If your computer is mememory limited use a smaller tile (e.g. 500).
#' @param outDir directory for the output file.
#' @keywords predict, landscape
#' @export
#' @examples
#' ### Testing
#' cov <- list.files("e:/tmpGIS/PEM_cvs/", pattern = "*.tif",full.names = TRUE)
#' cov <- cov[-(grep(cov, pattern = "xml"))]
#'
#' predict_landscape(model = "e:/tmp/model_gen_test/model.rds",
#'                   cov = cov,
#'                   tilesize = 1000,
#'                   outDir = "e:/tmp/predict_landscape")

predict_landscape <- function(model, cov,tilesize = 500,
                              outDir = "./predicted") {
  ## libraries  -----
    library(dplyr)
    library(mlr)

  ## Adjust names
  ## This will be used in the loop to rename stars object
  n <- basename(cov)
  n <- gsub(".tif", "", n)

  ## Load the model -----
  mod <- readRDS(model)


  ## Error handle -- model vs. cov -----------
  ## If names in model features are found in the cov list continue.
  ## ELSE exit with message
  if (length(setdiff(mod$features, n)) != 0) { ## tests if all model features are found in the cov list
    ## On model vs. cov error ---------------
    print("Name mis-match between the model features and the names of the rasters.")
    print("The following raster co-variates are not found in the model features list:")
    print(setdiff(mod$features, n))
  } else {
    dir.create(outDir) ## create output dir -----------

    ## create tiles ---------------
    tiles <- pemgeneratr::tile_index(cov[1], tilesize)

    ## alternate -- outside of pemgeneratr
    # source("./R/tile_index.R")  ## load the tile index function
    # tiles <- tile_index(cov[1], tilesize)


    ## begin loop through tiles -----

    ## set up progress messaging
    a <- 0 ## running total of area complete
    ta <- sum(as.numeric(sf::st_area(tiles)))


    for (i in 1:nrow(tiles)) {    ## testing first 2 tiles       ##nrow(tiles)) {
        t <- tiles[i,]  ## get tile
        print(paste("working on ", i, "of", nrow(tiles)))
        print("...")


        ## * load tile area---------
        print("... loading new data (from rasters)...")
        r <- stars::read_stars(cov,
                        RasterIO = list(nXOff  = t$offset.x[1]+1, ## hack -- stars and tile_maker issue??
                                        nYOff  = t$offset.y[1]+1,
                                        nXSize = t$region.dim.x[1],
                                        nYSize = t$region.dim.y[1]))

        ## * update names ---------
        names(r) <- n

        ## * convert tile to dataframe ---------
        rsf <- sf::st_as_sf(r, as_points = TRUE)
        # rsf <- na.omit(rsf)  ## na.omit caused issues
        rsf[is.na(rsf)] <- 0 ## rather provide a zero value

        ## * predict ---------

        if (nrow(rsf) == 0) {
          print("... Empty tile moving to next...")
        } else {
        print("... modelling outcomes (predicting)...")
        pred <- predict(mod, newdata = rsf)

        ## * geo-link predicted values ---------
        r_out <- cbind(rsf, pred)

        ## layers to keep (i.e. newly predicted layers)
        keep <- setdiff(names(r_out),
                        names(r))
        keep <- keep[-length(keep)] ## drops the last entry (geometry field, not a name)

        r_out <- r_out %>% dplyr::select(keep)


        ## change the text values to numeric values.
        r_out$response <- as.numeric(r_out$response)

        ## Set up subdirectories for rastertile outputs
        print("... exporting raster tiles...")
        for (k in keep) {
          dir.create(paste(outDir, k, sep = "/"))
        }



        ## * save tile (each pred item saved) ---------
        for (j in 1:length(keep)) {
          # j <- 2  ## testing
          out <- stars::st_rasterize(r_out[j],
                                       template = r[1])
          stars::write_stars(out,
                             paste0(outDir,"/",
                                    keep[j], "/",             #sub-directoy
                                    keep[j], "_", i, ".tif")) #tile name
        }

        ## * report progress -----
        a <- a + as.numeric(sf::st_area(t))
        print(paste(round(a/ta*100,1), "% complete"))
        print("") ## blank line

        } ## end if statement -- for when tile is empty
        } ## END LOOP -------------
    print("All predicted tiles generated")


    ## Save the names of the model response -----
    ## The levels are in the multiclass
    respNames <- levels(r_out$response) ## this becomes the dictionary to describe the raster values
    write.csv(respNames, paste(outDir, "response_names.csv",
                               sep = "/"),
              row.names = FALSE)


    ## Mosaic Tiles ---------------

    print("Generating raster mosaics")
    for (k in keep) {
      # get list of tiles
      r_tiles <- list.files(paste(outDir, k, sep = "/"),
                            pattern = ".tif",
                            full.names = TRUE)
      ## mosaic
      gdalUtils::mosaic_rasters(gdalfile = r_tiles, ## list of rasters to mosaic
                                dst_dataset = paste0(outDir, "/", k, ".tif"),  #output: dir and filename
                                output_Raster = TRUE) ## saves the raster (not just a virtual raster)

    }


  } ### end positive if statment ----------

} ### end function





