#!/usr/bin/env bash
set -eu

function print_usage() {
  echo "Usage: $0 <input-file> <layer-name> <output-gpkg> <mapping> <optional:ogr2ogr-arguments>"
  echo ""
  echo "<input-file>                    Input file; any file format that GDAL/OGR can read"
  echo ""
  echo "<layer-name>                    Layer name in input file"
  echo ""
  echo "<output-gpkg>                   Filepath of GeoPackage output"
  echo ""
  echo "<mapping>                       Path to attribute mapping file"
  echo ""
  echo "<optional:ogr2ogr-arguments>    Optional ogr2ogr arguments"
  echo ""
  echo "--help                          Print usage and exit"
}

if [[ $# -eq 0 ]] | [[ "$*" == *--help* ]] | [[ $# -lt 4 ]];then
    print_usage
    exit 1
fi

INPUT_FILE="$1"
LAYER_NAME="$2"
OUTPUT_GPKG="$3"
MAPPING="$4"
OGR_ARGS="${@:5}"

if ! test -f "$MAPPING"; then
  echo "$0: error occured"
  echo "<mapping> $MAPPING does not exist"
  exit 1
fi

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
ogr2ogr -f GPKG "$OUTPUT_GPKG" "$INPUT_FILE" -sql "$query" ${OGR_ARGS}
status=$?
if [ $status -eq 0 ]; then
    echo "$0: ran succesfully"
else
    echo "$0: error occured"
    rm "$OUTPUT_GPKG" &>/dev/null
fi