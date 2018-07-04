
setwd("/home/mario/Downloads/Colombia/humedad/2016")
library(raster)
library(rasterVis)
sm  <- stack(list.files(pattern='nc'), varname='sm')
cou <- raster::getData("GADM", country='COLOMBIA', level=1)
sm  <- crop(sm, cou)
idx <- seq(as.Date('2016-01-01'), as.Date('2016-12-31'), 'day')
sm <- setZ(sm, idx)
names(sm) <- idx
sm <- stack(sm)
smX <- stack(calc(sm, fun=mean, na.rm=TRUE),
calc(sm, fun=min, na.rm=TRUE),
calc(sm, fun=max, na.rm=TRUE))
names(smX) <- c('SMmean', 'SMmin', 'SMmax')
#plot(smX,col=colorRampPalette(c("gray", "brown", "blue"))(255))
densityplot(smX)
bwplot(sm, scales=list(x=list(at=c(10, 180, 350))))
smsp <- as(sm, 'SpatialPointsDataFrame')
plot(smsp, main='training sm-data-ESA-CCI')
plot(cou, add=TRUE)
saveRDS(smsp, file='SM-COL-2016.rds')
#end
 
