import geopandas as gpd
import pandas as pd
from shapely.geometry import Point

import os

# Nos cambiamos de directorio
os.chdir("../data")

# Cargamos los datos en csv
datos_row = pd.read_csv("Prionace_glaucaGBIF.csv")
# Con lat y long creamos las geometrías
geometry = [Point(xy) for xy in zip(datos_row.Longitude, datos_row.Latitude)]
# Creamos el geodataframe
datos_gpd = gpd.GeoDataFrame(datos_row, crs=4326, geometry=geometry)

# Obtenemos los límites de la capa
xmin,ymin,xmax,ymax = datos_gpd.total_bounds
print("Xmin: {}. Xmax: {}. Ymin: {}. Ymax: {}.".format(xmin,xmax,ymin,ymax))
# Guardamos como geojson
datos_gpd.to_file("Prionace_glaucaGBIF.geojson", driver='GeoJSON')
