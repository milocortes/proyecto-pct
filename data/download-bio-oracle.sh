#!/usr/bin/env bash
filename='bio-oracle-names-url.txt'

while read line; do

  nombre=$(echo $line | awk -F"[,]" '{print $1}')
  url=$(echo $line | awk -F"[,]" '{print $2}')
  zipname=$(echo $line | awk -F"[/]" '{print $6}')
  tiffname=$(echo $zipname | sed 's/....$//')
  nuevonombre="$nombre.tif"

  echo "Descargando: $nombre"
  wget $url
  unzip $zipname
  rm $zipname
  mv $tiffname $nuevonombre
  mv $nuevonombre ./raster

done < $filename
