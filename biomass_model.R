#!/usr/bin/env Rscript
#
# Estimation of urban biomass (add details here)
#
# Apply linear model to estimate biomass from NBCD, NLCAN, and NLCD data. It is
# assumed that all input data share teh same extent, projection, and resolution.
#
# Notes: 
#   - The raster package annoyingly changes the CRS when the file is written. To
#   get around this, an external routine (gdalcopyproj.py) is used to reset it
#   properly.
#   - For BU SCC: load the modules R/R-3.1.1, gdal, proj4, and python/2.7.5
#
# Brady Hardiman (the main guy)
# Keith Ma (technical assistance)
# April, 2015

# Define files
nbcd.f <- 'data/MA/ma_nbcd_clip2.tif' # NBCD filename
nlcan.f <- 'data/MA/ma_nlcan_clip.tif' # NLCAN filename
nlcd.f <- 'data/MA/ma_nlcd_clip.tif' # NCLD filename
out.all.f <- 'out/junk_all.tif' # output filename
out.urban.f <- 'out/junk_urban.tif' # output filename
out.forest.f <- 'out/junk_forest.tif' # output filename
out.other.f <- 'out/junk_other.tif' # output filename
out.format <- 'GTiff' # see ?writeFormats
out.type <- 'FLT4S' # see ?dataType
slope <- 0.29
intercept <- 0.25

# Define model 
model <- function(nbcd, nlcan, mask) {
  (slope*nlcan+intercept)*mask + nbcd*(mask==0)
}

# Load dependencies
library('raster')

# Create raster objects
nbcd.r <- raster(nbcd.f)
nlcan.r <- raster(nlcan.f)
nlcd.r <- raster(nlcd.f)

# Create mask (1 where urban, 0 elsewhere)
mask.urban.r <- calc(nlcd.r, fun = function(x){x>=21 & x<=24}) # 1 where urban, 0 elsewhere
mask.forest.r <- calc(nlcd.r, fun = function(x){(x>=41 & x<=43) | x==90}) # 1 where forest, 0 elsewhere
mask.other.r <- overlay(mask.urban.r, mask.forest.r, fun = function(x,y){x==0 & y==0}) # 1 where other, 0 elsewhere

# Apply model
out.all.r <- overlay(nbcd.r, nlcan.r, mask.urban.r, fun = model, 
                     filename = out.all.f, format = 'GTiff', dataType = 'FLT4S', overwrite = TRUE)

# Subset output by land cover
out.urban.r <- mask(out.all.r, mask.urban.r, maskvalue = 0, updatevalue = NA, 
                    filename = out.urban.f, format = 'GTiff', dataType = 'FLT4S', overwrite = TRUE)
out.forest.r <- mask(out.all.r, mask.forest.r, maskvalue = 0, updatevalue = NA, 
                    filename = out.forest.f, format = 'GTiff', dataType = 'FLT4S', overwrite = TRUE)
out.other.r <- mask(out.all.r, mask.other.r, maskvalue = 0, updatevalue = NA, 
                    filename = out.other.f, format = 'GTiff', dataType = 'FLT4S', overwrite = TRUE)

# Fix projection for output
system(paste('./gdalcopyproj.py', nbcd.f, out.all.f))
system(paste('./gdalcopyproj.py', nbcd.f, out.urban.f))
system(paste('./gdalcopyproj.py', nbcd.f, out.forest.f))
system(paste('./gdalcopyproj.py', nbcd.f, out.other.f))

# Done.
