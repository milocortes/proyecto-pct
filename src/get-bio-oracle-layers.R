# Load package
library(sdmpredictors)

# Seleccionamos las capas de Bio-ORACLE
layers.bio2 <- list_layers( datasets="Bio-ORACLE" )

# Para cortar las capas de acuerdo a los límites de las observaciones de GBIF
# Nuestros límites son:
#   Xmin: -173.160004. Xmax: 140.852728. Ymin: 21.3526. Ymax: 59.56.
#ne.atlantic.ext <- extent(-100, 45, 30.75, 72.5)
#temp.max.bottom.crop <- crop(temp.max.bottom, ne.atlantic.ext)
