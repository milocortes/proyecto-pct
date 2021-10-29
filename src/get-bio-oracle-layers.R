# Load package
library(sdmpredictors)

# Seleccionamos las capas de Bio-ORACLE
layers.bio2 <- list_layers( datasets="Bio-ORACLE" )

# %---- Capas a descargar ------% 
# Temperatura superficial de mar
#   * [157] "BO2_tempmean_bdmean--Sea water temperature (mean at mean depth)"                        
#   * [166] "BO2_templtmax_bdmean--Sea water temperature (longterm max at mean depth)"               
#   * [163] "BO2_temprange_bdmean--Sea water temperature (range at mean depth)"                      
#   * [255] "BO2_templtmax_ss--Sea surface temperature (longterm max)"                               
#   * [256] "BO2_templtmin_ss--Sea surface temperature (longterm min)"                               
#   * [257] "BO2_tempmax_ss--Sea surface temperature (maximum)"                                      
#   * [258] "BO2_tempmean_ss--Sea surface temperature (mean)"                                        
#   * [259] "BO2_tempmin_ss--Sea surface temperature (minimum)"                                      
#   * [260] "BO2_temprange_ss--Sea surface temperature (range)"   

# Salinidad
#   * [211] "BO2_salinitymean_bdmean--Sea water salinity (mean at mean depth)"                       
#   * [217] "BO2_salinityrange_bdmean--Sea water salinity (range at mean depth)"                     
#   * [223] "BO2_salinityltmin_bdmean--Sea water salinity (longterm max at mean depth)"              
#   * [546] "BO21_salinityltmax_ss--Sea surface salinity (longterm max)"                             
#   * [550] "BO21_salinityltmin_ss--Sea surface salinity (longterm min)"                             
#   * [554] "BO21_salinitymax_ss--Sea surface salinity (maximum)"                                    
#   * [558] "BO21_salinitymean_ss--Sea surface salinity (mean)"                                      
#   * [562] "BO21_salinitymin_ss--Sea surface salinity (minimum)"                                    

# Clorofila
#   * [261] "BO2_chlomax_ss--Chlorophyll concentration (maximum)"                                    
#   * [262] "BO2_chlomean_ss--Chlorophyll concentration (mean)"                                      
#   * [263] "BO2_chlomin_ss--Chlorophyll concentration (minimum)"                                    
#   * [264] "BO2_chlorange_ss--Chlorophyll concentration (range)"                                    
#   * [265] "BO2_chloltmax_ss--Chlorophyll concentration (longterm max)"                             
#   * [266] "BO2_chloltmin_ss--Chlorophyll concentration (longterm min)"    

# Para cortar las capas de acuerdo a los límites de las observaciones de GBIF
# Nuestros límites son:
#   Xmin: -173.160004. Xmax: 140.852728. Ymin: 21.3526. Ymax: 59.56.
#ne.atlantic.ext <- extent(-100, 45, 30.75, 72.5)
#temp.max.bottom.crop <- crop(temp.max.bottom, ne.atlantic.ext)
