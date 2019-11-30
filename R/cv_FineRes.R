#' Push inputlist to a fine resolution.
#'
#' Uses raster::disagregate to push a set of rasters to a target resolution.  Note that input raster resolution need to be divisible by the target resolution.
#'
#' @param inputFileList a character vector specifiying the location of all the input rasters.  Input list should only be a raster type (e.g. .tif).  Best practice is to use list.files(full.names = TRUE).
#' @param output destination of the output files.
#' @param targetRes desired resolution to convert to.
#' @keywords raster, disaggregate
#' @export
#' @examples
#' l <- list.files("e:/covariates/10")
#' cv_FineRes(l, output = "e:/covariates/2.5")


cv_FineRes <- function(inputFileList, output = "e:/tmp/2.5", targetRes = 2.5){

  ifelse(!dir.exists(file.path(output)),              #if tmpOut Does not Exists
         dir.create(file.path(output), recursive = TRUE), "Directory Already Exisits")        #create tmpOut

  for(i in inputFileList){
    ### testing parms
    # i  <- inputFileList[1]
    # targetRes <- 2.5
    # output = "e:/tmp/2.5/"
    print(paste("Processing:", i))
    r  <- raster::raster(i)
    px <- raster::res(r)[1]
    r  <- raster::disaggregate(r, px/targetRes)  ## This will through an error if not an integer
    raster::writeRaster(r, paste(output, basename(i), sep = "/"), overwrite = TRUE)
  }
}
