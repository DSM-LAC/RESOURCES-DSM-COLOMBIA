library(raster)
library(caret)
library(doMC)
library(doParallel)

sm <- readRDS('SM-VEN-2016.rds')

wg <- stack('/home/mario/Downloads/Colombia/humedad/VEN_worldgridsCOVS.tif')
names(wg) <- readRDS('/home/mario/Downloads/Colombia/humedad/worldgridsCOVS_names.rds')

smrm <- cbind(sm@data, extract(wg, sm))

saveRDS(smrm, file='reg-mat-sm-cci-2016-VEN.rds')

smrm$averageSM <-rowMeans(smrm[1:366], na.rm = TRUE)
smX <- na.omit(smrm[367:485])

##VARIABLE IMPORTANCE 

cl <- makeCluster(detectCores(), type='PSOCK')
registerDoParallel(cl)
control2 <- rfeControl(functions=rfFuncs, method="repeatedcv", number=5, repeats=5)
(RFE_RF_model <- rfe(smX[-119], smX[,119], sizes=c(1:6), rfeControl=control2) )

plot(RFE_RF_model, type=c("g", "o"))
predictors(RFE_RF_model)
stopCluster(cl = cl)

##SOIL MOISTURE PREDICTION

beginCluster(5)
library(randomForest)
(predRFE <- clusterR(wg, predict, args=list(model=RFE_RF_model)))
plot(predRFE, col=colorRampPalette(c("gray", "brown", "blue"))(255))
endCluster()
