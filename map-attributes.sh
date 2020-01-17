#!/usr/bin/env bash
set -eu

function print_usage() {
  echo "Usage: $0 --input-file <input-file> --layer-name <layer-name> --output-gpkg <output-gpkg> --mapping <mapping>"
  echo ""
  echo "--input-file <input-file>        Input file; any file format that GDAL/OGR can read"
  echo ""
  echo "--layer-name <layer-name>        Layer name in input file"
  echo ""
  echo "--output-gpkg <output-gpkg>      Filepath of GeoPackage output"
  echo ""
  echo "--mapping <mapping>              Path to attribute mapping file"
  echo ""
  echo "--help                           Print usage and exit"
}

if [[ $# -eq 0 ]];then
    print_usage
    exit 1
fi

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --input-file)
    INPUT_FILE="$2"
    shift
    shift
    ;;
    --layer-name)
    LAYER_NAME="$2"
    shift
    shift
    ;;
    --output-gpkg)
    OUTPUT_GPKG="$2"
    shift
    shift
    ;;
    --mapping)
    MAPPING="$2"
    shift
    shift
    ;;
    --help)
    print_usage
    exit 0
    ;;
    *)
    print_usage
    exit 1
    ;;
  esac
done

attributes=""
while read -r line; do
  old_att=$(echo $line | cut -d' ' -f1)
  new_att=$(echo $line | cut -d' ' -f2)
  if [ -z "$attributes" ]; then
    attributes="$old_att as $new_att"
  else
    attributes="$attributes, $old_att as $new_att"
  fi
done<"$MAPPING"

query="SELECT $attributes from $LAYER_NAME"

set +e
ogr2ogr -f GPKG "$OUTPUT_GPKG" "$INPUT_FILE" -sql "$query" -nln "$LAYER_NAME"
status=$?
echo ""
if [ $status -eq 0 ]; then
    echo "$0: ran succesfully"
else
    echo "$0: error occured"
    rm "$OUTPUT_GPKG" &>/dev/null
fi