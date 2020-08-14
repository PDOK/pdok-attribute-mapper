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

function att_in_attributes(){
  att=$1
  attributes=$2
  test1=$(echo $attributes | grep -E ",$att")
  test2=$(echo $attributes | grep -E "^$att")

  if [[ -z $test1 && -z $test2 ]];then
    echo "false"
  else
    echo "true"
  fi
}

function list_attributes(){
  input_file=$1
  layer=$2
  line_nr="$(ogrinfo "$input_file" "$layer" -so | grep -n -e ".*=.*" | head -n 1 | cut -d ":" -f1)"
  att_info="$(ogrinfo "$input_file" "$layer" -so | tail -n +$line_nr)"
  geom_column=$(echo "$att_info" | grep -n -e 'Geometry Column\s=\s' | awk '{ print $4 }')

  only_atts="$(echo "$att_info" | tail -n +3)"
  output=""
  while read -r line; do
    column=$(echo "$line" | awk '{ print $1 }')
    column=${column%:}
    if [[ -z $output ]];then
      output="$column"
    else
      output="$output,$column"
    fi
  done < <(echo "$only_atts")
  echo $output,$geom_column
}


all_attributes=$(list_attributes "$INPUT_FILE" "$LAYER_NAME")
echo "$all_attributes"
attributes=""
while read -r line; do
  old_att=$(echo $line | cut -d' ' -f1)
  new_att=$(echo $line | cut -d' ' -f2)

  att_in_attributes=$(att_in_attributes $old_att $all_attributes)
  if [[ "$att_in_attributes" == "false" ]];then
    continue
  fi

  if [[ "$new_att" == "-" ]]; then
    continue
  fi

  if [ -z "$attributes" ]; then
    attributes="$old_att as $new_att"
  else
    attributes="$attributes, $old_att as $new_att"
  fi
  # remove attribute from the all_atrributes list
  all_attributes="${all_attributes/$old_att,/}"
  all_attributes="${all_attributes/$old_att/}"
  # remove trailing comma
  all_attributes=${all_attributes%,}
done<"$MAPPING"

select_statement="$attributes"
if [[ -z $select_statement ]];then
  select_statement=$all_attributes
else
  select_statement=$select_statement,$all_attributes
fi

query="SELECT $select_statement from $LAYER_NAME"
echo $query

set +e 
ogr2ogr -f GPKG "$OUTPUT_GPKG" "$INPUT_FILE" -sql "$query" -nln "$LAYER_NAME" -lco "FID=id" ${OGR_ARGS}
status=$?
if [ $status -eq 0 ]; then
    echo "$0: ran succesfully"
else
    echo "$0: error occured"
    rm "$OUTPUT_GPKG" &>/dev/null
fi