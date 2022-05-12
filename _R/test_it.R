## sample test creation of covariates

library(raster)
library(pemgeneratr)



## TEST Create Covariates -----------------

dtm <- raster("d:/ProjectData/SampleData/alrf_sample.tif")
dtm

create_covariates(dtm, SAGApath = "c:/SAGA/", output = "d:/tmp2")


create_covariates(dtm, SAGApath = "c:/SAGA/", output = "d:/tmp3",
                  layers = c("Filled_sinks", "WindExp"))





