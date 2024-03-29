
remove.packages("pemgeneratr")
## Initialize Package ----------------------------------
# # install.packages("devtools")
library("devtools")
# devtools::install_github("klutometis/roxygen")
library(roxygen2)
#
# create("PEMWorkFlow")
# setwd("e:/workspace/2020/PEM")
# setwd("~/workspace/2020/PEM/pemGenertaR/")
list.files()


## Compile Documentation -------------------------------
# setwd("./pemGenertaR//")
document()



## Install Package
# setwd("..")
install("../pemgeneratr", upgrade = FALSE)
# ??PEMgeneratr::aoi_snap ## Confirm help file works


# setwd("./pemgeneratr")

library(pemgeneratr)
?pemgeneratr::make_lines()
?pemgeneratr::create_covariates()
?pemgeneratr::st_erase()
