#' Provides multiple resolutions of the input raster
#'
#' Resamples raster to specified desired resolution using the raster package.
#' NOTE: an attempt was made to use the SAGA resample but I had trouble aligning the rasters. I am sure that gdal can be used but for now funtioning is internal to R packages.
#'
#' For the PEM project we generally start with a high resolution dtm.  Resampling to a set of lower resolution DTMs is used to capture multi-scale influences on the ecological unit.
#' NOTE: to ensure raster stacking of all covariates this operation should be completed only on data that has been cropped to the AOI using aoi_snap()
#'
#' @parm input a raster object (not a file)
#' @parm resolution = c(5, 10, 25)  multiple resolutions can be specified
#' @parm SAGApath is the path to SAGA installation -- needed for windows machines.
#' @keywords DTM, resampling, SAGA
#' @export
#' @example
#' ##
#'


multi_res <- function(input, output="CoVars", resolution = c(2.5, 5, 10, 25), SAGApath = "C:/SAGA/"){


  # ##testing
  # setwd("e:/workspace/2019/PEM_2020/data/")
  # input <- raster::raster("dtm_cropped.tif")
  # resolution <- c(2.5, 5, 10, 25)
  # iMetrics <- raster(input)
  # # r <- rgdal::readGDAL(input)
  # rtn <- getwd()
  # # setwd("../data/")
  # output <- "CoVars"
  # # SAGApath <- "C:/SAGA/"

  # OUTPUTS: ------------------------------------------------------------
  ifelse(!dir.exists(file.path(output)),              #if tmpOut Does not Exists
         dir.create(file.path(output)), "Directory Already Exisits")        #create tmpOut

  ## Load input and get information from it
  r <- input
  e <- as.vector(raster::extent(r))
  # e
  proj <- raster::crs(r)
  raster::res(r)

  for(i in resolution){
    ##Testing
     # i <- resolution[4]

    ## create a target raster:: to tun the 1m to 2.5m raster -- contrained to the extent
    target <- raster::raster(ncol=10, nrow=10, xmn=e[1], xmx=e[2], ymn=e[3], ymx=e[4]) ## empty raster
    raster::res(target) <- i ## Makes target resolution
    raster::projection(target) <-  raster::crs(r)
    # target

    r2 <- raster::resample(r, target)  ## resamples the DTM to the target specified
    # raster::plot(r2)
    # raster::extent(r2)

    outdir <- paste(output, i, sep = "/")
    ifelse(!dir.exists(file.path(outdir)),              #if tmpOut Does not Exists
           dir.create(file.path(outdir)), "Directory Already Exisits")        #create tmpOut

    ## Name Adjustments
    outname <- input@data@names[1]
    outsuf <- paste0("_", i, ".tif")
    outname <- paste0(outname, outsuf)

    raster::writeRaster(r2, paste(outdir, outname, sep = "/"), overwrite = TRUE)

    r <- r2 ## reassigning raster for resampling -- step-wise resampling instead of resamping all from original.

  }
}


## confirms same extent
# library(raster)
# l <- list.files("CoVars/", pattern = "*.tif", recursive = TRUE, full.names = TRUE)
#
# for(i in l){
# c <- raster(i)
# print(as.vector(extent(c)))
# }

  #
  # ## Create a SAGA version of the input file
  # r <- rgdal::readGDAL(input)
  #
  # outname <- gsub(".tif", ".sdat" , input)
  # rgdal::writeGDAL(r, paste(saga_tmp_files, outname, sep="/"), driver="SAGA")
  #
  # saga_in <- paste(output, "saga", outname, sep = "/")  ## realtive filename of input saga file
  ## Begin loop through resolutions


    # outsuf <- paste0("_", i ,".sdat")  ## new file ending
    # saga_out <- gsub(".sdat", outsuf, outname)    ## extra care naming so that I can call these after
    # saga_outfull <- paste0(saga_tmp_files, saga_out)  ## pushes it to the saga sub-directory
    #
    # sysCMD <- paste(saga_cmd, "grid_tools", "Resampling", "-TARGET_DEFINITION 0",
    #                 "-INPUT", saga_in,
    #                 "-KEEP_TYPE",  "true",
    #                 "-SCALE_UP",    5,  ## mean value
    #                 "-SCALE_DOWN",  3,  ## B-spline Interpolation
    #                 "-TARGET_USER_SIZE", i,  ## Output resolution
    #                 # "-TARGET_USER_FITS,  0", ## Fits to Nodes (1 would be cells)
    #                 "-OUTPUT", saga_outfull)
    # system(sysCMD)
    #



#
#
#
#     ### Create Sub-directory to final processed file
#     subdir <- paste(output, i, sep = "/")
#     # print(subdir)
#     ifelse(!dir.exists(file.path(subdir)),              #if tmpOut Does not Exists
#            dir.create(file.path(subdir)), print("Directory Already Exisits"))        #create tmpOut
#
#
#
#
#     ## Save a geo-Tiff of the resolution
#     out_tif <- gsub(".sdat", ".tif", saga_out)
#     out_tif <- paste(subdir, out_tif, sep = "/")
#
#     r <- rgdal::readGDAL(saga_outfull)
#     rgdal::writeGDAL(r, out_tif, drivername = "GTiff")
#
#     r <- raster::raster(out_tif) ## conferming header details are intact
#     r
#     raster::extent(r)
#
#     ## DO WE WANT TO START WITH 1m or the last resampled (i.e. 1 - > 5, 10, 25)
#
#     ## ##### >> Resample to resolution  -----------------------------
#     # http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_preprocessor_5.html
#
#
#
#
#
#
#     #
#     #               -ELEV" , sDTM,          # Input DTM
#     #                 "-FILLED", input,                                 # Output
#     #                 "-MINSLOPE ", 0.1                                       # Default Parameters
#     # )
#     # print(sysCMD)
#     # system(sysCMD)
#     #
#
#   }
#
#
#
#   ## Covert to Saga format for processing ---------------------------------------
#   rtnwd <- getwd() ## wd to return to
#   setwd(saga_tmp_files)
#
#   sDTM <- "dtm.tif"
#   # sDTM <- paste0(saga_tmp_files, sDTM)
#   raster::writeRaster(dtm, sDTM, drivername = "GTiff", overwrite = TRUE)  # save SAGA Version using rgdal
#
#
#
#
#
#
#   for(i in resolution){
#     print(i)
#
#
#   }
#
#
#
#
# #### Old
#   ## Begin Function ################################################################
#   ##### Link SAGA to R --------------------------------------------------
#   if(Sys.info()['sysname']=="Windows"){saga_cmd = paste0(SAGApath, "saga_cmd.exe")
#   } else {saga_cmd = "saga_cmd"}  ;
#   z<- system(paste(saga_cmd, "-v"), intern = TRUE)  ## prints that SAGA version number -- confirming it works.
#   print(z)
#
#   saga_tmp_files <- paste0(output,"/saga/")
#   ifelse(!dir.exists(file.path(saga_tmp_files)),              #if tmpOut Does not Exists
#          dir.create(file.path(saga_tmp_files)), print("Directory Already Exisits"))        #create tmpOut
#
#
