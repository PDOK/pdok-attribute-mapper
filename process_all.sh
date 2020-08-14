#!/usr/bin/env bash
set -eu

GPKG_FILE=${1:-"cbsgebiedsindelingen_2020_v2.gpkg"} 
OUTPUT_FILE=${2:-"cbsgebiedsindelingen_2020_v3.gpkg"} 

rm -f "$OUTPUT_FILE"

while read -r LINE; do
    echo $LINE
    if [[ -f $OUTPUT_FILE ]];then
        ./map-attributes.sh $GPKG_FILE $LINE  $OUTPUT_FILE ./example/mapping.txt -update -t_srs EPSG:28992
    else
        ./map-attributes.sh $GPKG_FILE $LINE  $OUTPUT_FILE ./example/mapping.txt -t_srs EPSG:28992
    fi
done< <(ogrinfo $GPKG_FILE  | tail -n +3 | awk '{ print $2}' | sort)