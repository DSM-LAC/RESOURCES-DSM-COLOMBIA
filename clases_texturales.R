library(raster)
library(soiltexture)


## Cargamos las capas necesarias
SAND <- raster("Arena_60_100.tif")
SILT <- raster("Limo_60_100.tif")
CLAY <- raster("Arcilla_60_100.tif")
textura.df <- as.data.frame(cbind(values(SAND),values(SILT),values(CLAY)))
names(textura.df) <- c("SAND","SILT","CLAY")
textura.df <- TT.normalise.sum(tri.data=textura.df,tri.pos.tst=FALSE)
completos <- !is.na(textura.df)[,1]
incompletos <- is.na(textura.df)[,1]
textura.df$CLASS[completos] <- TT.points.in.classes(tri.data=textura.df[completos,], class.sys="USDA.TT", PiC.type="t", tri.pos.tst=F)
textura.df$CLASS <- as.factor(textura.df$CLASS)
table(textura.df$CLASS)
clases <- levels(textura.df$CLASS)

## Y obtenemos el raster
textura.r <- setValues(SAND, as.numeric(textura.df$CLASS))
plot(textura.r, col=rainbow(length(clases)), legend=F)
legend("bottomright", legend=clases, fill=rainbow(length(clases)), cex=0.6)

writeRaster(textura.r, file="Textura_sub_suelo.tif", 
            overwrite=TRUE)
