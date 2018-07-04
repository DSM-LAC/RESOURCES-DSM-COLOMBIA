
setwd("/home/mario/Downloads/Colombia/humedad/2016")
library(raster)
sm  <- stack(list.files(pattern='nc'), varname='sm')
cou <- raster::getData("GADM", country='COLOMBIA', level=1)
sm  <- crop(sm, cou)
sm <- as(sm, 'SpatialPointsDataFrame' )
saveRDS(sm, file='SM-COL-2016.rds')
#end
 
