### Limpiamos ambiente de trabajo
rm(list = ls())

# Cargamos bibliotecas
library(sdm)
library(raster)
library(ecospat)
library(usdm)
library(biomod2)

setwd("/home/milo/PCIC/Maestría/3erSemestre/ptc/proyectos/proyecto-hcc/github/output")
# Cargamos los datos de Prionace_glauca
datos <- read.csv("/home/milo/PCIC/Maestría/3erSemestre/ptc/proyectos/proyecto-hcc/github/data/Prionace_glaucaGBIF_sub.csv")

# Cargamos los raster
bioracle <- stack(list.files(path="/home/milo/PCIC/Maestría/3erSemestre/ptc/proyectos/proyecto-hcc/github/data/raster/", pattern = "tif", full.names = T))
# Cortamos el área de análisis
prionace_area<- raster(xmn=-173.160004,xmx=-107.0375,ymx=59.56,ymn=21.3526)
bioracle_crop <- crop(bioracle,prionace_area)
# particionamos los datos en dos conjuntos ("calibración" y "validación")
pts <- datos[c("Longitude","Latitude")]
selected <- sample(1:nrow(pts), nrow(pts) * 0.5)
train <- pts[selected,]
test <- pts[-selected,]
pts.all <- rbind(train,test)


# convertir el primer raster de los bios en puntos
bioracle.pts<-rasterToPoints(bioracle_crop[[1]],fun=NULL, spatial=TRUE)
bioracle.all<-raster::extract(bioracle[[1]],bioracle.pts)
bioracle.all<-data.frame(coordinates(bioracle.pts),bioracle.all)

# generar pseudo-ausencias para los datos de calibración
presences_train<- train
dim(presences_train)
pseudo_abs_train<- ecospat.rand.pseudoabsences(nbabsences=80,
                                               glob=bioracle.all,colxyglob=1:2, colvar=1:2, presence=presences_train,
                                               colxypresence=1:2, mindist=0.1)

pseudo_abs_train<- pseudo_abs_train[,1:2]
presences_train["Rep1"] <- 1
presences_train <- plyr::rename(presences_train, replace=c("Longitude"="x", "Latitude"="y"))
pseudo_abs_train["Rep1"] <- 0


# Combino las presencias y las pseudo-absences del conjunto de calibración
DataSpeciesTrain.spp <-rbind(presences_train, pseudo_abs_train)

# generar pseudo-ausencias para los datos de validación
presences_test <- test
presences_test["Rep1"] <- 1
presences_test <- plyr::rename(presences_test, replace=c("Longitude"="x", "Latitude"="y"))
dim(presences_test)
pseudo_abs_test<- ecospat.rand.pseudoabsences(nbabsences=800,
                                              glob=bioracle.all,colxyglob=1:2, colvar=1:2, presence=presences_test,
                                              colxypresence=1:2, mindist=0.1)

pseudo_abs_test<-pseudo_abs_test[,1:2]
pseudo_abs_test["Rep1"] <- 0

# Combino las presencias y las pseudo-absences del conjunto de validación
DataSpeciesTest.spp <- rbind(presences_test, pseudo_abs_test)

# Convierto los dataframes en objectos espaciales
DataSpecies <- SpatialPointsDataFrame(coords =DataSpeciesTrain.spp[,c(1,2)], data = DataSpeciesTrain.spp,
                                      proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
TestSpecies <- SpatialPointsDataFrame(coords =DataSpeciesTest.spp[,c(1,2)], data = DataSpeciesTest.spp,
                                      proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
DataSpecies <- DataSpecies[,c(-1,-2)]
TestSpecies <- TestSpecies[,c(-1,-2)]

# Generamos un mapa con cada conjunto de datos
plot(DataSpecies)
plot(TestSpecies)

# La función vifcor identifica las variables que deben ser excluidas
v1 <- vifcor(bioracle_crop, th=0.7)

bioracle.red <- exclude(bioracle_crop, v1)

# Ajustar los datos a los requirimientos específicos del paquete sdm
d1 <- sdmData(formula=Rep1~., train=DataSpecies, test=TestSpecies, predictors=bioracle.red)

m1 <- sdm(Rep1~., data=d1, methods=c('rf','glm','bioclim'),
          replicatin='sub', test.percent=30, n=2)

m1
roc(m1)

# Generar un ensamble con los mejores modelos usando el método de promedio ponderado (weighted averaging) con base en la métrica (TSS: True Statistics Skill)
e1 <- ensemble(m1,newdata=bioracle.red,filename='e1.img', setting=list(method='weighted',stat='TSS'))
plot(e1)

# Generamos un mapa binario usando un criterio de umbral de mínima área predicha y donde le asignamos un error de 10% a los datos de presencia que no usamos para calibrar.
xy <- train
coordinates(xy) <- ~Longitude+Latitude
mpa.e1 <- ecospat.mpa(e1, xy, perc = .9)
mpa.e1
bin.e1 <- ecospat.binary.model(e1, mpa.e1)
plot(bin.e1)

# Generar proyecciones a futuro.
# RCP 2.6 2050
url <- "/home/milo/PCIC/Maestría/3erSemestre/ptc/proyectos/proyecto-hcc/github/data/cmip/"
rcps <- c("rcp26","rcp45","rcp85")
anios <- c("2050","2100")
capas <- c('BO21_salinitymin_ss.tif','BO2_chlomin_ss.tif','BO2_salinitymean_bdmean.tif','BO2_tempmean_bdmean.tif','BO2_temprange_ss.tif')

for (rcp in rcps) {
  for (anio in anios) {
    url_rcp<-paste(url,rcp,"/",anio,"/",sep="")
    print(url_rcp)
    capas_lista <- list()

    for (i in c(1:length(capas))) {
      capas_lista[[i]] <- raster(paste(url_rcp,capas[i],sep=""))
      capas_lista[[i]] <- crop(capas_lista[[i]],prionace_area)
    }

    stack_capas_lista <- stack(capas_lista)

    # generar la proyección futura sobre el ensamble
    nombre_archivo <- paste(rcp,"_",anio,'_fut.img',sep="")
    nombre_archivo_jpg <- paste(rcp,"_",anio,'_fut.jpg',sep="")
    e1.fut <- ensemble(m1,newdata=stack_capas_lista,filename=nombre_archivo, setting=list(method='weighted',stat='TSS'))
    # Generar el binario para el escenario futuro
    bin.e1.fut <- ecospat.binary.model(e1.fut, mpa.e1)
    jpeg(paste("binario_",nombre_archivo_jpg,sep=""))
    plot(bin.e1.fut)
    dev.off()
    # Ahora vamos a identificar áreas de estabilidad, ganancia y pérdida de áreas (i.e., número de pixeles). Ya tenemos los mapas binarios para el periodo actual y el futuro (0, 1). Usaremos una función del paquete Biomod2 (BIOMOD_RangeSize).
    # Primero tenemos que tener la misma resolución espacial en ambos rasters.

    crs.geo <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")  # geographical, datum WGS84
    bin.e1.r <- projectRaster(from=bin.e1, to=bin.e1.fut, crs=crs.geo, method="bilinear")
    cambio <- BIOMOD_RangeSize(bin.e1.r, bin.e1.fut, SpChange.Save=NULL)
    jpeg(paste("perdida_ganancia_",nombre_archivo_jpg,sep=""))
    plot(cambio$Diff.By.Pixel)
    dev.off()
  }
}
