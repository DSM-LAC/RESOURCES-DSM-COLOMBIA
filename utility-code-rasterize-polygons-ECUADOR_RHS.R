#load libraries
library(raster)
library(rgdal)
#load reference raster or raster stack
s <- stack('ECUtopo.tif')
#read polygon to rasterize
rh <- readOGR(dsn=getwd(), layer="R_HUMEDAD_SUELOS_RHS_ECU")
#saveRDS(rh, file='rhs.rds')
#rasterize
ras <- rasterize(rh, s, "RHS")
ras <- as.factor(ras)
levels(ras) <- levels(rh$RHS)
#save new raster
writeRaster(f, file='rasterizedRHS.tif')
#add new raster to topographic predictors
#s <- stack(s, SPP2)
#writeRaster(s, file='ECUtopo_RHS.tif')
