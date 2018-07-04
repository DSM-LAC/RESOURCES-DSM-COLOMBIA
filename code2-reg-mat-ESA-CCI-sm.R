library(raster)
library(caret)
library(doMC)
library(doParallel)

sm <- readRDS('SM-COL-2016.rds')
topo <- stack(readRDS('/home/mario/Downloads/Colombia/humedad/topoCOL.rds'))
smrm <- cbind(sm@data, extract(topo, sm))
smrm$averageSM <-rowMeans(smrm[1:366], na.rm = TRUE)
smX <- na.omit(smrm[367:382])

##VARIABLE IMPORTANCE 

cl <- makeCluster(detectCores(), type='PSOCK')
registerDoParallel(cl)
control2 <- rfeControl(functions=rfFuncs, method="repeatedcv", number=5, repeats=5)
(RFE_RF_model <- rfe(smX[-16], smX[,16], sizes=c(1:6), rfeControl=control2) )
plot(RFE_RF_model, type=c("g", "o"))
predictors(RFE_RF_model)[1:8]
stopCluster(cl = cl)

##SOIL MOISTURE PREDICTION

beginCluster(5)
library(randomForest)
(predRFE <- clusterR(topo, predict, args=list(model=RFE_RF_model)))
plot(predRFE, col=colorRampPalette(c("gray", "brown", "blue"))(255))
endCluster()
