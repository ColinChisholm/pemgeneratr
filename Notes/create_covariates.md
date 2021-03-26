
if {layers }


options <- c("Filled_sinks", "sinkroute", "dem_preproc", "slope_aspect_curve",
             "tCatchment", "tca", "sCatchment", "twi", "channelsNetwork",
             "Distance2Water", "MultiResFlatness", "MultiResFlatness2",
             "MultiResFlatness3", "TRI", "convergence", "Openness",
             "dah", "TPI", "RidgeValley", "MRN", "FlowAccumulation",
             "SlopeLength", "FlowAccumulation2", "FlowAccumulation3",
             "FlowPathLength", "FlowPathLength2", "FlowPathLength3", "LSFactor",
             "SolarRad", "Convexity"




## Includes:
slope_aspect_curve  covers:   slope, aspect, gencurve, totcurve
tca                 includes: flowlength4
Distance2Water                hdist, vdist
Distance2Water2               hdistnob, vdistnob
MultiResFlatness              mrvbf, mrrtf
MultiResFlatness2             mrvbf2, mrrtf2
MultiResFlatness3             mrvbf5, mrrtf5
Openness                      open_pos, open_neg
RidgeValley                   val_depth, rid_level
MRN                           mnr_area, mnr_mheight, mnr
FlowAccumulation              flow_accum_ft, MeanOvCatch, AccumMaterial,
FlowAccumulation3             flow_accum_td, MeanOvCatchTD, AccumMaterialTD, FlowPathLenTD
SolarRad                      direinso, diffinso






## Relies on
dem_preproc           sinksRoute
sCatchment  relies on tCatchment, sinksFilled
twi         relies on sCatchment, slope
channelsNetwork       tCatchment
Distance2Water        sinksFilled, channelsNetwork
Distance2Water2       sinksFilled, channelsNetwork
RidgeValley           sinksFilled
MRN                   sinksFilled
FlowAccumulation      sinksFilled
SlopeLength           sinksFilled
FlowAccumulation      sinksFilled
FlowAccumulation2     sinksFilled
FlowAccumulation3     sinksFilled
FlowPathLength        sinksFilled
FlowPathLength2       sinksFilled
FlowPathLength3       sinksFilled
LSFactor              tCatchment, sinksFilled,
Convexity             sinksFilled



##Questions to discuss with Gen
dem_preproc -- generated but not used for anything else

Overland distance to water -- two versions ... minor differences. Which one to keep?
MRVBF 3 versions
Distance to water 2 versions
Flow Accumulation - 3 versions



Grossnickle
fall plant had best shoot and root development but highest drought risk on drier sites.
