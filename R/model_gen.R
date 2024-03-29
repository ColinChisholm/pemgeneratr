#' Generate a machine learning model
#'
#' This function takes in all the data needed to produce machine learning model.
#' Inputs are handed to a RMD report/ script.
#' Outputs include the markdown report, the cross validation object,
#' and a binary model (RDS) that can then be used to predict on new data.
#'
#'
#' @param outDir  Highly recommended to be set as an absolute directory.  This defaults to the project's root directory OR where the RMD script is saved.
#' Additional products generated from the associated `model_gen_XXX.Rmd`` markdown scripts will also be saved to this dir.
#' @param traindat Is a dataframe that contains the model training data.  The reponse variable should be one of the columns.
#' @param target   The name of the response variable in the traindat data frame.
#' @param mType **rF** for a `ranger` random forest; **tidy** for a tidymodels version using ranger; **esb** for an `ensemble` of `ranger`, `glmnet`, `xgboost`, and `nnTrain``; _others to be added_.  This acts as a suffix for which model_gen_XXX.Rmd to call.
#' @param trees   A random forest parameter for the number of trees to use.
#' @param rseed    Optional random number seed.
#' @keywords machine-learning, model, report
#' @export
#' @examples
#' dat <- read.csv("e:/workspace/2020/PEM/ALRF_PEMv2/dev/modDat.csv",
#'                stringsAsFactors = TRUE)
#'
#'
#' model_gen(traindat = dat,
#'           target = "SiteSeries",
#'           outDir = "e:/tmp/model_gen_test",
#'           mType = "rF",
#'           trees = 500,
#'           rseed = 456)


model_gen <- function(traindat, target, mType = "rF", outDir = ".", trees = 500, rseed = NA) {
  ## create destination folder
  ifelse(!dir.exists(file.path(outDir)),                # if folder does not exist
          dir.create(file.path(outDir), recursive = TRUE),
          FALSE)         # create it


  ## Convert to data frame -------------------
  if("sf" %in% class(traindat)) {
    traindat <- as.data.frame(traindat)
    traindat <- traindat[, -length(traindat)]
    print("Data is a sf object -- converted to dataframe for modelling")
  }

  ## error testing ----------------
  if (sum(is.na(traindat[,target])) > 0) {
    # print(paste("There are,", sum(is.na(traindat[,target]))  , "NA values in the target:", target))
    stop(paste("There are,", sum(is.na(traindat[,target]))  , "NA values in the target:", target))
  }

  ## call report -- passing variables to it --------------
  RMD <- system.file("rmd",
                     paste0("model_gen_", mType, ".Rmd"), ## note calls mType -- to specify the type of model to use
                     package = "pemgeneratr") ## this syntax designed for a package install.
  # RMD <- "./R/model_gen.Rmd"  ## manually set for sourcing this function

  ## had some trouble with relative filenames
  outDir <- normalizePath(outDir)



  rmarkdown::render(RMD,              ## where the rmd is located
                    params = list(traindat = traindat,  ## parameters to send to rmarkdown
                                  target   = target,
                                  outDir = outDir,
                                  rseed = rseed,
                                  trees = trees),
                    output_dir = outDir)                ## where to save the report

  ## open the report
  browseURL(paste0(outDir, "/model_gen_", mType, ".html"))
}




