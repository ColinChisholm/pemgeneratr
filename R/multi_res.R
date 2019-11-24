#' Provides multiple resolutions of the input raster
#'
#' Resamples raster to specified desired resolution using the default SAGA "Resampling" grid tool.
#'
#' For the PEM project we generally start with a high resolution dtm.  Resampling to a set of lower resolution DTMs is used to capture multi-scale influences on the ecological unit.
#' NOTE: to ensure raster stacking of all covariates this operation should be completed only on data that has been cropped to the AOI using aoi_snap()
#'
#' @parm input is location the raster file for processing (tested with input as GeoTiff)
#' @parm resolution = c(5, 10, 25)  multiple resolutions can be specified
#' @parm SAGApath is the path to SAGA installation -- needed for windows machines.
#' @keywords DTM, resampling, SAGA
#' @export
#' @example
#' ##
#'


multi_res <- function(input, output="CoVars", resolution = c(2.5, 5, 10, 25), SAGApath = "C:/SAGA/"){

}




  ##testing
  setwd("e:/workspace/2019/PEM_2020/data/")
  input <- "dtm_cropped.tif"
  resolution <- c(2.5, 5, 10, 25)
  iMetrics <- raster(input)
  # r <- rgdal::readGDAL(input)
  rtn <- getwd()
  # setwd("../data/")
  output <- "CoVars"
  SAGApath <- "C:/SAGA/"

  ## Begin Function ################################################################
  ##### Link SAGA to R --------------------------------------------------
  if(Sys.info()['sysname']=="Windows"){saga_cmd = paste0(SAGApath, "saga_cmd.exe")
  } else {saga_cmd = "saga_cmd"}  ;
  z<- system(paste(saga_cmd, "-v"), intern = TRUE)  ## prints that SAGA version number -- confirming it works.
  print(z)





  # OUTPUTS: ------------------------------------------------------------
  ## sets up tested file folders for all covariates
  ifelse(!dir.exists(file.path(output)),              #if tmpOut Does not Exists
         dir.create(file.path(output)), print("Directory Already Exisits"))        #create tmpOut


  saga_tmp_files <- paste0(output,"/saga/")
  ifelse(!dir.exists(file.path(saga_tmp_files)),              #if tmpOut Does not Exists
         dir.create(file.path(saga_tmp_files)), print("Directory Already Exisits"))        #create tmpOut


  ## Create a SAGA version of the input file
  r <- rgdal::readGDAL(input)

  outname <- gsub(".tif", ".sdat" , input)
  rgdal::writeGDAL(r, paste(saga_tmp_files, outname, sep="/"), driver="SAGA")

  saga_in <- paste(output, "saga", outname, sep = "/")  ## realtive filename of input saga file
  ## Begin loop through resolutions
  for(i in resolution){
    ##Testing
    i <- resolution[1]


    outsuf <- paste0("_", i ,".sdat")  ## new file ending
    saga_out1 <- gsub(".sdat", outsuf, outname)
    saga_out2 <- paste0(saga_tmp_files, saga_out)

    sysCMD <- paste(saga_cmd, "grid_tools", "Resampling", "-TARGET_DEFINITION 0",
                    "-INPUT", saga_in,
                    "-KEEP_TYPE",  "true",
                    "-SCALE_UP",    5,  ## mean value
                    "-SCALE_DOWN",  3,  ## B-spline Interpolation
                    "-TARGET_USER_SIZE", i,  ## Output resolution
                    # "-TARGET_USER_FITS,  0", ## Fits to Nodes (1 would be cells)
                    "-OUTPUT", saga_out2)
    system(sysCMD)




    ###
    subdir <- paste(output, i, sep = "/")
    print(subdir)
    ifelse(!dir.exists(file.path(subdir)),              #if tmpOut Does not Exists
           dir.create(file.path(subdir)), print("Directory Already Exisits"))        #create tmpOut


    ## ##### >> Resample to resolution  -----------------------------
    # http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_preprocessor_5.html






    #
    #               -ELEV" , sDTM,          # Input DTM
    #                 "-FILLED", input,                                 # Output
    #                 "-MINSLOPE ", 0.1                                       # Default Parameters
    # )
    # print(sysCMD)
    # system(sysCMD)
    #

  }



  ## Covert to Saga format for processing ---------------------------------------
  rtnwd <- getwd() ## wd to return to
  setwd(saga_tmp_files)

  sDTM <- "dtm.tif"
  # sDTM <- paste0(saga_tmp_files, sDTM)
  raster::writeRaster(dtm, sDTM, drivername = "GTiff", overwrite = TRUE)  # save SAGA Version using rgdal






  for(i in resolution){
    print(i)


  }
