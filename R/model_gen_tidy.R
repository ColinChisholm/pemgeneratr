#' Generate a machine learning model using tidy models
#'
#' This function takes in all the data needed to produce machine learning model.
#' Inputs are handed to a RMD report/ script.
#' Outputs include the markdown report, the cross validation object,
#' and a binary model (RDS) that can then be used to predict on new data.
#'
#'
#' @param trDat   Is a dataframe that contains the model training data.  The response variable should be one of the columns.
#' @param outDir  Highly recommended to be set as an absolute directory.  This defaults to the project's root directory OR where the RMD script is saved.
#' Additional products generated from the associated `model_gen_tidy.Rmd`` markdown script will also be saved to this dir.
#' @param mname    Name for this model run.  Will be used to name outputs.
#' @param target   The name of the response variable in the trDat data frame.
#' @param target2  A second target
#' @param tid      Transect ID ... need to clarify how this is different from `field transect`
#' @param field_transect A transect ID ... need to clarify how this is different from `tid`
#' @param slice    Column ID for _slices_ from Conditioned Latin Hyper Sampling
#' @param ds_ratio Covariate/predictor variable balancing: downsample proportion
#' @param sm_ratio Covariate/predictor variable balancing: Smote proportion
#' @param rseed    Optional random number seed.
#' @param infiles  Simply for reporting -- to specify what files were used in the creation of trDat.
#' @param mmu      Map unit (e.g. BC BEC subzone).  This may be a column in the input data and will allow for the processing of multiple subzones in one model run.
#' @keywords       machine-learning, random forest, model, report
#' @export
#' @examples
#'
#'

model_gen_tidy <- function(trDat,
                           outDir = ".",
                           mname = "Model",
                           target = "target",
                           target2 = NA,
                           tid = NA,
                           field_transect = NA,
                           slice = NA,
                           ds_ratio = NA,
                           sm_ratio = NA,
                           rseed = NA,
                           infiles = NA,
                           mmu = NA)
{
  ## create destination folder
  ifelse(!dir.exists(file.path(outDir)),                # if folder does not exist
          dir.create(file.path(outDir)), FALSE)         # create it

  ## error testing ----------------
  if (sum(is.na(trDat[,target])) > 0) {
     stop(paste("There are,", sum(is.na(trDat[,target]))  , "NA values in the target:", target))
   }


  #RMD <- "D:/PEM_DATA/BEC_DevExchange_Work/_functions/model_gen_tidy.Rmd"
  #RMD <- "D:/GitHub/PEM_Methods_DevX/_functions/model_gen_tidy.Rmd"

  rmarkdown::render("model_gen_tidy_2201.Rmd",              ## where the rmd is located
                    params = list(
                      trDat     = trDat,
                      outDir    = outDir,
                      mname     = mname,
                      target    = target,
                      target2   = target2,
                      tid       = tid,
                      field_transect = field_transect,
                      slice     = slice,
                      ds_ratio  = ds_ratio,
                      sm_ratio  = sm_ratio,
                      rseed     = rseed,
                      infiles   = infiles,
                      mmu       = mmu
                      ),
                  output_dir = outDir)                ## where to save the report

  file.rename(paste0(outDir,"/", "model_gen_tidy.html"), paste0(outDir,"/", mname,"_report.html"))
  ## open the report
  browseURL(paste0(paste0(outDir,"/", mname,"_report.html")))
}
