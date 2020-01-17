# pdok-attribute-mapper

Scripts for renaming of attributes of geospatial files. It is a wrapper script around the GDAL/OGR `ogr2ogr` command line utility. To rename attributes, supply the following inputs:

- `<input_file>`: input file that needs attribute renaming
- `<output_gpkg>`: output GeoPackage with renamed attributes
- `<mapping>`: mapping file with each line containing: `${old_attribute_name}\t${new_attribute_name}`, see the example folder. Every attribute of the input file needs to mapped, otherwise the attribute will be omitted in the output GeoPackage
- `<layer_name>`: target layer in the input file 

## Depedencies

Requires GDAL/OGR to be installed and the `ogr2ogr` command line utility needs to be available in the `$PATH` (environment variable), see [gdal.org](https://gdal.org/). 


## Usage

### bat script

```
map-attributes.bat --mapping example/mapping.txt  --input-file /vsizip/example/CBS_PC4_2015_v2.zip --layer-name CBS_PC4_2015_v2 --output-gpkg CBS_PC4_2015_v2.gpkg
```

### bash script

```
./map-attributes.sh  --input-file /vsizip/example/sample_shape.zip --layer-name sample_shape --output-gpkg sample.gpkg --mapping example/mapping.txt
```