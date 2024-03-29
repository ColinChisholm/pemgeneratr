#' Covariate generation from input dtm
#'
#' Takes a dtm and generates the covariates embeded in this function.
#' Note that this uses a tools generated by SAGA and as such the correct path to SAGA needs to be specified.
#'
#' UNDER DEVEOPMENT -- see hack at ~49
#'
#' @param dtm is a dtm raster object
#' @keywords SAGA, covariates, predictors, raster
#' @export
#' @examples
#' ## Load sf object


cv_dtm <- function(dtm, SAGApath = "C:/SAGA/", output = "./cv-rasters"){
  ## create output if it does not exist
  ifelse(!dir.exists(file.path(output)),              #if tmpOut Does not Exists
          dir.create(file.path(output), recursive = TRUE), "Directory Already Exisits")        #create tmpOut
  # Testing
  # setwd("e:/workspace/2019/PEM_2020")
  # output = "./cv-rasters"
  # SAGApath = "C:/SAGA/"

##### Link SAGA to R --------------------------------------------------
  if(Sys.info()['sysname']=="Windows"){saga_cmd = paste0(SAGApath, "saga_cmd.exe")
  } else {saga_cmd = "saga_cmd"}  ;
  z<- system(paste(saga_cmd, "-v"), intern = TRUE)  ## prints that SAGA version number -- confirming it works.
  print(z)


# OUTPUTS: ------------------------------------------------------------
    ifelse(!dir.exists(file.path(output)),              #if tmpOut Does not Exists
           dir.create(file.path(output)), print("Directory Already Exisits"))        #create tmpOut

    saga_tmp_files <- paste0(output,"/saga/")
    ifelse(!dir.exists(file.path(saga_tmp_files)),              #if tmpOut Does not Exists
           dir.create(file.path(saga_tmp_files)), print("Directory Already Exisits"))        #create tmpOut



## Covert to Saga format for processing ---------------------------------------
    rtnwd <- getwd() ## wd to return to
    setwd(saga_tmp_files)

    sDTM <- "dtm.tif"
    # sDTM <- paste0(saga_tmp_files, sDTM)
    raster::writeRaster(dtm, sDTM, drivername = "GTiff", overwrite = TRUE)  # save SAGA Version using rgdal

## Bit of a hack here -- SAGA does not like the output from raster package
## save it as gTiff, re-open using rgdal and export as SAGA ...
    dtm <- rgdal::readGDAL(sDTM)

    sDTM <- "dtm.sdat"
    ## If the file exists delete and save over.
      if(file.exists(sDTM)){
        unlink(sDTM)
        rgdal::writeGDAL(dtm, sDTM, drivername = "SAGA")  ## TRUE
      } else {
        rgdal::writeGDAL(dtm, sDTM, drivername = "SAGA" )               ## FALSE
      }
## END HACK ------------------

## ##### >> 1 -- Fill Sinks XXL (Wang and Liu)  -----------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_preprocessor_5.html
    sinksFilled <- "Filled_sinks.sgrd"
    sysCMD <- paste(saga_cmd, "ta_preprocessor 5", "-ELEV" , sDTM,          # Input DTM
                    "-FILLED", sinksFilled,                                 # Output
                    "-MINSLOPE ", 0.1                                       # Default Parameters
    )
    # print(sysCMD)
    system(sysCMD)

##### >> 2 -- Total Catchment Area --------------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_hydrology_0.html
    tCatchment <- "tCatchment.sgrd"
    sysCMD <- paste(saga_cmd, "ta_hydrology 0", "-ELEVATION", sinksFilled,  # Input from 1
                    "-FLOW", tCatchment,                                    # Output
                    "-METHOD", 4                                            # Default Parameters
    )
    system(sysCMD)

##### >> 3 -- Flow Width and Specific Catchment Area --------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_hydrology_19.html
    sCatchment <- "Specific_Catchment.sgrd"
    sysCMD <- paste(saga_cmd, "ta_hydrology 19", "-DEM", sinksFilled,       # Input from 1
                    "-SCA", sCatchment,                                     # Output
                    "-TCA", tCatchment,                                     # Input from 2
                    "-METHOD", 1                                            # Parameters
    )
    system(sysCMD)

##### >> 4 -- Channel Network -------------------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_channels_0.html
# https://sourceforge.net/projects/saga-gis/files/SAGA%20-%20Documentation/SAGA%20Documents/SagaManual.pdf/download
    channelsNetwork <- "Channel_network_grid.sgrd"
    sysCMD <- paste(saga_cmd, "ta_channels 0", "-ELEVATION", sinksFilled,     # Input from 1
                    "-CHNLNTWRK", channelsNetwork,                            # Output
                    "-INIT_GRID", tCatchment,                                 # Input from 2
                    "-INIT_VALUE", 1000000, "-INIT_METHOD", 2,                # Based on SAGA Manual Documentation, p. 119
                    "-DIV_CELLS", 5.0, "-MINLEN", 10.0                        # Default Parameters
    )
    system(sysCMD)

##### >> 5 -- Overland Flow Distance to Channel Network -----------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_channels_4.html
    hDistance <- "OverlandFlowDistance.sgrd"
    vDistance  <- "VerticalDistance.sgrd"
    sysCMD <- paste(saga_cmd, "ta_channels 4", "-ELEVATION", sinksFilled,   # Input from 1
                    "-CHANNELS", channelsNetwork,                             # Input from 4
                    "-DISTANCE", hDistance, "-DISTVERT", vDistance,           # Outputs
                    "-METHOD", 1, "-BOUNDARY", 1                              # Parameters
    )
    system(sysCMD)

##### >> 6 -- MRVBF -----------------------------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_8.html
    MRVBF <- "MRVBF.sgrd"
    MRRTF <- "MRRTF.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 8", "-DEM", sDTM,             # Input DTM
                    "-MRVBF", MRVBF, "-MRRTF", MRRTF,                       # Outputs
                    "-T_SLOPE", 16, "-T_PCTL_V", 0.4, "-T_PCTL_R", 0.35,    # Default Parameters
                    "-P_SLOPE", 4.0, "-P_PCTL", 3.0, "-UPDATE", 0,
                    "-CLASSIFY", 0,"-MAX_RES", 100
    )
    system(sysCMD)

##### >> 7 -- Terrain Ruggedness Index ----------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_16.html
    TRI <- "TRI.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 16", "-DEM", sDTM,            # Input DTM
                    "-TRI", TRI,                                            # Output
                    "-MODE", 1, "-RADIUS", 3.0, "-DW_WEIGHTING", 0          # Parameters
    )
    system(sysCMD)

##### >> 8 -- Convergence Index -----------------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_1.html
    convergence <- "Convergence.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 1", "-ELEVATION ", sDTM,      # Input DTM
                    "-RESULT", convergence,                                 # Output
                    "-METHOD", 1, "-NEIGHBOURS", 1                          # Parameters
    )
    system(sysCMD)

##### >> 9 -- Openness --------------------------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_lighting_5.html
    POS <- "OpennessPositive.sgrd"
    NEG <- "OpennessNegative.sgrd"
    sysCMD <- paste(saga_cmd, "ta_lighting 5", "-DEM", sDTM,                # Input DTM
                    "-POS", POS, "-NEG", NEG,                               # Outputs
                    "-RADIUS", 1000, "-METHOD", 1,                          # Default Parameters
                    "-DLEVEL",  3, "-NDIRS", 8
    )
    system(sysCMD)

##### >> 10 -- Diuranal Anisotropic Heating -----------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_12.html
    dAH <- "dAH.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 12", "-DEM", sDTM,            # Input DTM
                    "-DAH", dAH,                                            # Output
                    "-ALPHA_MAX", 202.5                                     # Default Parameters
    )
    system(sysCMD)


##### >> 11 -- Slope Aspect and Curvature -------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_0.html
    Slope <- "Slope.sgrd"
    Aspect <- "Aspect.sgrd"
    Curvature <- "gCurvature.sgrd"
    tCurve <- "tCurve.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 0", "-ELEVATION", sDTM,       # Input DTM
                    "-SLOPE", Slope, "-ASPECT", Aspect,                     # Outputs
                    "-C_GENE", Curvature, "-C_TOTA", tCurve,                # Outputs
                    "-METHOD", 6, "-UNIT_SLOPE", 0, "-UNIT_ASPECT", 0       # Default Parameters
    )
    system(sysCMD)

##### >> 12 -- Topogrphic Position Index --------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_morphometry_18.html
    TPI <- "TPI.sgrd"
    sysCMD <- paste(saga_cmd, "ta_morphometry 18", "-DEM", sDTM,            # Input DTM
                    "-TPI", TPI,                                            # Output
                    "-STANDARD", 0, "-RADIUS_MIN", 0, "-RADIUS_MAX", 100,   # Default Parameters
                    "-DW_WEIGHTING", 0, "-DW_IDW_POWER", 1,
                    "-DW_IDW_OFFSET", 1, "-DW_BANDWIDTH", 75
    )
    system(sysCMD)

##### >> 13 -- Topographic Wetness Index --------------------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_hydrology_20.html
    TWI <- "TWI.sgrd"
    sysCMD <- paste(saga_cmd, "ta_hydrology 20", "-SLOPE", Slope,           # Input from 11
                    "-AREA", sCatchment,                                    # Input from 3
                    "-TWI", TWI,                                            # Output
                    "-CONV",0,  "-METHOD", 0                                # Default Parameters
    )
    system(sysCMD)

##### >> 14 -- Potential Incoming Solar Radiation -----------------------
# http://www.saga-gis.org/saga_tool_doc/7.2.0/ta_lighting_2.html
    DirInsol <- "dirinsol.sgrd"
    DifInsol <- "difinsol.sgrd"
    sysCMD <- paste(saga_cmd, "ta_lighting 2", "-GRD_DEM", sDTM,            # Input DTM
                    "-GRD_DIRECT", DirInsol, "-GRD_DIFFUS", DifInsol,       # Outputs
                    "-SOLARCONST", 1367, "-LOCALSVF", 1, "-SHADOW", 0,      # Parameters
                    "-LOCATION", 1, "-PERIOD", 2, "-DAY", "2018-02-15",
                    "-DAY_STOP", "2019-02-15", "-DAYS_STEP", 30,
                    "-HOUR_RANGE_MIN", 0, "-HOUR_RANGE_MAX", 24,
                    "-HOUR_STEP", 0.5, "-METHOD", 2, "-LUMPED", 70
    )
    system(sysCMD)



setwd(rtnwd)

#### Convert to GeoTif --------------------------------
## Collect tmp saga file names


  ## TEST paramaters
  output <- "e:/tmp"

  tmpFiles <- paste(output, "saga", sep = "/")
  l <- list.files(path = tmpFiles, pattern = "*.sdat")
  l <- l[!grepl(".xml", l)] ## removes xmls from the list
  print(l)

  ## OutFile Suffix Use resolution as suffix for out filename
  r <- raster::raster(paste(tmpFiles, l[1], sep= "/"))
  subFolder <- raster::res(r)[1]  ##
  suf <- paste0("_", subFolder, ".tif")
  outList <- gsub(".sdat", suf, l)

## Loop through files and convert to tif
  for(i in 1:length(l)){

    ## parms for testing
    # i <- 1

    #actions
    r <- l[i]
    inFile <- paste(tmpFiles, r, sep = "/")
    # print(inFile)
    r <- raster::raster(inFile)



    outFile <- paste(output, subFolder, outList[i], sep = "/")  ## Names output

    ifelse(!dir.exists(file.path(paste(output, subFolder, sep = "/"))),              #if tmpOut Does not Exists
           dir.create(file.path(paste(output, subFolder, sep = "/"))),
           "Directory Already Exisits")        #create tmpOut

    raster::writeRaster(r, outFile, overwrite = TRUE)  ## Saves at 25m resolution


  }

## Remove tmp saga files
  unlink(paste(output, "saga", sep = "/"), recursive = TRUE)
}

