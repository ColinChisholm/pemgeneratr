% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cov_dtm.R
\name{cov_dtm}
\alias{cov_dtm}
\title{Covariate generation from input dtm
DEPRECIATED: use create_covariates.R}
\usage{
cov_dtm(dtm, SAGApath = "C:/SAGA/", output = "./cv-rasters")
}
\arguments{
\item{dtm}{is a dtm raster object}
}
\description{
Takes a dtm and uses SAGA GIS to generate the covariates embeded in this function.
Note: the correct path to SAGA needs to be specified.
}
\examples{
##
cov_dtm(dtm,                          ## the dtm (loaded by raster() )
        SAGApath = "C:/SAGA/"         ## specify location of SAGA on your machine
        output   = "c:/dtm-derived" ) ## specify output folder
}
\keyword{SAGA,}
\keyword{covariates,}
\keyword{predictors,}
\keyword{raster}
