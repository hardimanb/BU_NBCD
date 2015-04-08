# Estimation of urban biomass (add details here)
#
# Apply linear model to estimate biomass from NBCD, NLCAN, and NLCD data. It is
# assumed that all input data share teh same extent, projection, and resolution.
#
# Brady Hardiman (the main guy)
# Keith Ma (technical assistance)
# April, 2015

# Define files
nbcd.f <- 'data/MA/ma_nbcd_clip2.tif' # NBCD filename
nlcan.f <- 'data/MA/ma_nlcan_clip.tif' # NLCAN filename
nlcd.f <- 'data/MA/ma_nlcd_clip.tif' # NCLD filename
out.f <- 'out/junk.tif' # output filename
out.format <- 'GTiff' # see >writeFormats
out.type <- 'FLT4S' # see ?dataType

# Define model 
model <- function(nbcd, nlcan, nlcd) {
  1.1*nbcd + 0.0*nlcan + 0.0*nlcd  
}

# Load dependencies
library('raster')

# Create raster objects
nbcd.r <- raster(nbcd.f)
nlcan.r <- raster(nlcan.f)
nlcd.r <- raster(nlcd.f)

# Apply model
out.r <- overlay(nbcd.r, nlcan.r, nlcd.r, fun = model, filename = out.f, 
                 format = 'GTiff', dataType = 'FLT4S', overwrite = TRUE)

# Done.