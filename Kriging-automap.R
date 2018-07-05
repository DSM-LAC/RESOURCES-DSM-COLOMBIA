#load datasets
d <- read.csv('VenezuelaRegMatrix.csv')
cou <- raster::getData("GADM", country='VENEZUELA', level=1)

#required libraries
library(automap)
library(raster)
library(Metrics)

#prepare data
d <- d[c(3,4,5)]
coordinates(d) =~ longitude+latitude
proj4string(d) <- CRS(projection(cou))
d <- spTransform(d, CRS('+init=epsg:32619'))
cou <- spTransform(cou, CRS('+init=epsg:32619'))

#Kriging as implemented in automap
kriging_result = autoKrige(log(OCSKGM30)~1, d)
#KrPred <- mask(stack(kriging_result$krige_output), cou)
plot(kriging_result)

     # Ordinary kriging, no new_data object
     kriging_result2 = autoKrige(log(OCSKGM30)~1, d, cou)
     plot(kriging_result2)

#validate (10-fold CV)
d = d[which(!duplicated(d@coords)), ]
d.cv <- autoKrige.cv(log(OCSKGM30)~1,d)
val <- d.cv$krige.cv_output

#visualize results
plot(val$observed, val$var1.pred)
rmse(val$observed, val$var1.pred)
cor(val$observed, val$var1.pred)^2
#saveRDS(Kriging_result, file='Krige-results.rds')
#end

