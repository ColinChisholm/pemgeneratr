<center>
<h1>
`PEMgeneratr`
</h1>
</center>

``` r
library(sf)
library(raster)
library(rgdal)
library(tmap)

library(PEMgeneratr) ## OUR NEW PACKAGE
```

Purpose
=======

Provide a package of tools to support British Columbia’s Predictive
Ecosystem Mapping project

The General workflow includes:

1.  Generation of multi-scale covariates. Many of these created from
    high-resolution digital terrain models.
2.  Creation of the <tt>Stage 1</tt> sampling plan based on conditioned
    Latin Hypercube sampling (cLHS)
3.  Processing of <tt>Stage 1</tt> field data
4.  Generation of <tt>PEM\_v1</tt> that including:
    -   predictive map of all ecological units (i.e. site series)
    -   probability maps for each eco-unit
    -   Entropy raster showing where highest uncertainty exists
5.  Generation of <tt>Stage 2</tt> sampling plan
    -   masks out areas of high certainty – removing these from sampling
    -   locates points for sampling using cLHS
    -   optimizes field data transect locations – maximizing the
        variability from the <tt>PEM\_v1</tt>
6.  Processing of <tt>Stage 2</tt> field data
7.  Generation of a final Predictive Ecosystem Map

The scenario example
====================

For demonstration purposes a harvest block from the [Aleza Lake Research
Forest](http://alrf.unbc.ca) has been selected to predict the ecosystem
classes within the block area using British Columbia’s
Biogeoclassification system
([BGC](https://www.for.gov.bc.ca/hre/becweb/index.html)).

Generate Co-variates
====================

To start this package will examine DTM derived layers. *Note:
incorporation of satelite data is scheduled for development.*

Additionally, for this example a small sub-set of data is use.
Additional scripting will be needed to tile data for parrallel process
and landscape level analysis.

Area of interest.
-----------------

A polygon is loaded and the extent of that polygon is used to determine
the area of interest. However, in order to get the various resolutions
of data to stack well, essential for later proceesing, it is *critically
important* that the all corners of the area of interest are divisible by
the resolutions to be generated (i.e. 2.5, 5, 10, and 25m<sup>2</sup>).
To accomplish this the raw aoi interest polygon’s extent is pushed out
to the nearest 100m.

``` r
aoi_raw <- st_read("../data/block.gpkg", quiet = TRUE)
e <- as(extent(aoi_raw), "SpatialPolygons") ## for use in map below.

aoi <- aoi_snap(aoi_raw)
```

    ## [1] "initial extent is:"
    ##      xmin      ymin      xmax      ymax 
    ##  558347.9 5994757.5  559700.9 5995734.5 
    ## [1] "Expanded extent is:"
    ##    xmin    ymin    xmax    ymax 
    ##  558300 5994700  559800 5995800

Intial Digital Terrain Models
-----------------------------

Here the DTM is loaded and cropped to the area of interest. The multiple
resolutions of the DTM are generated, and then the co-variates are
generated.

*Note for the project we have decided to start with 2.5m<sup>2</sup> as
the finest pixel resolution.* For easier processing throughout the
remainder of this project the extent of this initial dtm needs to be to
be constrained to the nearest 10m interval.

### Load DTM

``` r
# dtm <- data(dtm) ## Sample data provided -- ACTION DOCUMENT THIS.... not working 
dtm <- raster("../data/dtm.tif")

dtm_e <- as(extent(dtm), "SpatialPolygons") ## for use later 
# saveRDS(dtm, "./data/dtm.rds")
dim(dtm); extent(dtm)
```

    ## [1] 1835 2226    1

    ## class      : Extent 
    ## xmin       : 557905 
    ## xmax       : 560131 
    ## ymin       : 5994293 
    ## ymax       : 5996128

### Crop DTM

The DTM is cropped to the aoi expanded out to the nearest 100m. This
will allow for stacking of multi resolution layers later.

``` r
# aoi <- st_transform(aoi, crs(dtm))
dtm <- crop(dtm, aoi)
dim(dtm) ; extent(dtm)
```

    ## [1] 1100 1500    1

    ## class      : Extent 
    ## xmin       : 558300 
    ## xmax       : 559800 
    ## ymin       : 5994700 
    ## ymax       : 5995800

``` r
# writeRaster(dtm, "../data/dtm_cropped.tif", overwrite = TRUE )
```

### DTM Extent Optimizized

Below the original extent of the DTM is in red. The oringial area of
interest is in green, based on the shapefile received is in green, and
the adjusted area of interest is the color raster dtm. This new extent
is based on an adjusted area of interest – expanded out to the nearest
100m.

![](README_files/figure-markdown_github/unnamed-chunk-5-1.png)

Generate Multi-resolutions: `multi_res()`
-----------------------------------------

Ecological processes take place across different scales. In an effort to
incorporate this into the modeling process multiple scales of covariates
are generated. This project will work with resolutions of 2.5, 5, 10,
and 25m<sup>2</sup>. This function takes the input raster and resamples
it to the target resolutions while ensuring that all rasters have the
same exact extent – allowing for stacking of the rasters later.

``` r
multi_res(dtm, output = "../data/CoVars", resolution = c(2.5, 5, 10, 25))

# confirms same extent
l <- list.files("../data/CoVars/", pattern = "*.tif", recursive = TRUE, full.names = TRUE)

for(i in l){
# i <- l[1]  
c <- raster(i)
print(i)
print("Resolution")
print(res(c))
print(as.vector(extent(c)))
}
```

    ## [1] "../data/CoVars//10/dtm_10.tif"
    ## [1] "Resolution"
    ## [1] 10 10
    ## [1]  558300  559800 5994700 5995800
    ## [1] "../data/CoVars//2.5/dtm_2.5.tif"
    ## [1] "Resolution"
    ## [1] 2.5 2.5
    ## [1]  558300  559800 5994700 5995800
    ## [1] "../data/CoVars//25/cvs/saga/dtm.tif"
    ## [1] "Resolution"
    ## [1] 25 25
    ## [1]  558300  559800 5994700 5995800
    ## [1] "../data/CoVars//25/dtm_25.tif"
    ## [1] "Resolution"
    ## [1] 25 25
    ## [1]  558300  559800 5994700 5995800
    ## [1] "../data/CoVars//5/dtm_5.tif"
    ## [1] "Resolution"
    ## [1] 5 5
    ## [1]  558300  559800 5994700 5995800

Generate terrain co-variates: `cv_dtm()`
----------------------------------------

This function makes external calls for SAGA GIS to create the
co-variates.

Note that these functions *did not* work with the bundled OSgeo4W (SAGA
2.1). Make sure you have an installation of [SAGA
7.x](https://sourceforge.net/projects/saga-gis/).

*Function works! I am running the 10m to start – just to confirm it all
works* \_Next, I will convert to geoTif and clean up the tmp files data
and convert these to tif

For demonstration the 25m raster is co-variates are genearated.

``` r
dtm <- raster("../data/CoVars/25/dtm_25.tif")

output_CoVars <- "../data/CoVars/25/cvs"

if(!dir.exists(output_CoVars)){
  cv_dtm(dtm, SAGApath = "C:/SAGA/", output = output_CoVars )
}
```

``` r
list.files(path = paste(output_CoVars, "saga", sep = "/"), pattern = "*.sdat")
```

    ##  [1] "Aspect.sdat"                      
    ##  [2] "Aspect.sdat.aux.xml"              
    ##  [3] "Channel_network_grid.sdat"        
    ##  [4] "Channel_network_grid.sdat.aux.xml"
    ##  [5] "Convergence.sdat"                 
    ##  [6] "Convergence.sdat.aux.xml"         
    ##  [7] "dAH.sdat"                         
    ##  [8] "dAH.sdat.aux.xml"                 
    ##  [9] "difinsol.sdat"                    
    ## [10] "difinsol.sdat.aux.xml"            
    ## [11] "dirinsol.sdat"                    
    ## [12] "dirinsol.sdat.aux.xml"            
    ## [13] "dtm.sdat"                         
    ## [14] "Filled_sinks.sdat"                
    ## [15] "Filled_sinks.sdat.aux.xml"        
    ## [16] "gCurvature.sdat"                  
    ## [17] "gCurvature.sdat.aux.xml"          
    ## [18] "MRRTF.sdat"                       
    ## [19] "MRRTF.sdat.aux.xml"               
    ## [20] "MRVBF.sdat"                       
    ## [21] "MRVBF.sdat.aux.xml"               
    ## [22] "OpennessNegative.sdat"            
    ## [23] "OpennessNegative.sdat.aux.xml"    
    ## [24] "OpennessPositive.sdat"            
    ## [25] "OpennessPositive.sdat.aux.xml"    
    ## [26] "OverlandFlowDistance.sdat"        
    ## [27] "OverlandFlowDistance.sdat.aux.xml"
    ## [28] "Slope.sdat"                       
    ## [29] "Slope.sdat.aux.xml"               
    ## [30] "Specific_Catchment.sdat"          
    ## [31] "Specific_Catchment.sdat.aux.xml"  
    ## [32] "tCatchment.sdat"                  
    ## [33] "tCatchment.sdat.aux.xml"          
    ## [34] "tCurve.sdat"                      
    ## [35] "tCurve.sdat.aux.xml"              
    ## [36] "TPI.sdat"                         
    ## [37] "TPI.sdat.aux.xml"                 
    ## [38] "TRI.sdat"                         
    ## [39] "TRI.sdat.aux.xml"                 
    ## [40] "TWI.sdat"                         
    ## [41] "TWI.sdat.aux.xml"                 
    ## [42] "VerticalDistance.sdat"            
    ## [43] "VerticalDistance.sdat.aux.xml"
