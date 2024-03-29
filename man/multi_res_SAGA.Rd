% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/multi_res_SAGA.R
\name{multi_res_SAGA}
\alias{multi_res_SAGA}
\title{Provides multiple resolutions of the input raster.}
\usage{
multi_res_SAGA(
  input,
  output = "CoVars",
  resolution = c(2.5, 5, 10, 25),
  SAGApath = ""
)
}
\arguments{
\item{input}{list of rasters to process}

\item{output}{folder to save files.
#' @param resolution = c(5, 10, 25)  multiple resolutions can be specified}

\item{SAGApath}{Is the location of SAGA on your system.  On linux systems with SAGA GIS installed Use \code{SAGApath = ""}}
}
\description{
Resamples raster to specified desired resolution using SAGA GIS.
NOTE: an attempt was made to use the SAGA resample but I had trouble aligning the rasters. I am sure that gdal can be used but for now funtioning is internal to R packages.
}
\details{
For the PEM project we generally start with a high resolution dtm.  Resampling to a set of lower resolution DTMs is used to capture multi-scale influences on the ecological unit.
NOTE: to ensure raster stacking of all covariates this operation should be completed only on data that has been cropped to the AOI using aoi_snap()
}
\examples{
## generate default raster sizes
multi_res(r)
}
\keyword{resample}
