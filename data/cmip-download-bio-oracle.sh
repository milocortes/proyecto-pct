#!/usr/bin/env bash
filename='cmip-bio-oracle-names-url.txt'

while read line; do

  nombre=$(echo $line | awk -F"[,]" '{print $1}')
  url=$(echo $line | awk -F"[,]" '{print $3}')
  zipname=$(echo $line | awk -F"[/]" '{print $6}')
  tiffname=$(echo $zipname | sed 's/....$//')

  diruno=$(echo $nombre | awk -F"[_]" '{print $1}')
  dirdos=$(echo $nombre | awk -F"[_]" '{print $2}')
  directorio="./cmip/$diruno/$dirdos"

  wget $url
  unzip $zipname
  rm $zipname
  mv $tiffname $directorio

done < $filename
