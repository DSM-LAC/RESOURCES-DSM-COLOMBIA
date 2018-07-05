library(caret)
library(doMC)
library(doParallel)
library(reshape)
library(Metrics)
library(caretEnsemble)
library(snowfall)
library(raster)
library(ranger)
library('sp')
library('gstat')
library('parallel')
library(quantregForest)

inTrain <- createDataPartition(y = smX[,119], p = .75, list = FALSE)
training <- smX[ inTrain,]
testing <- smX[-inTrain,]

ls(getModelInfo())

set.seed(102)
ctrl <- trainControl(savePred=T, method="repeatedcv", number=5, repeats=5)
cl <- makeCluster(detectCores(), type='SOCK')
registerDoParallel(cl)
(models <- caretList(training[predictors(RFE_RF_model)[1:5]], training[,119], trControl=ctrl ,
methodList=c("glm", "rf", "pls","kknn", "svmLinear")))
ens <- caretEnsemble(models)
stopCluster(cl = cl)

resamps <- resamples(models)

#ens <- readRDS('caretEnsemble-LAC.rds')
beginCluster()
(predEns <- clusterR(wg[[predictors(RFE_RF_model)[1:5]]], predict, args=list(model=ens, keepNA=FALSE)))
#writeRaster(predEns, file=paste0(lev[i], 'V2-LACensembleSOC.tif'), 
overwrite=TRUE) 
#endCluster()

#uncertainty

testing$res <- (testing$OCSKGM - predict(ens, testing[-c(1,2,3)], keepNA=FALSE))

model <- quantregForest(y=testing$res, x=testing[-c(1,2,3,132)], ntree=500, keep.inbag=TRUE)
#beginCluster(6,type="SOCK")
#Estimate model uncertainty
unc <- clusterR(co[[names(testing[-c(1,2,3,132)])]], predict, args=list(model=model,what=sd))
writeRaster(unc, file=paste0(lev[i], 'RESIDUALmapQRF-LACensembleSOC.tif'), 
overwrite=TRUE) 



