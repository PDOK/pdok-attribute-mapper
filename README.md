# pdok-attribute-mapper

Scripts for renaming of attributes of geospatial files. It is a wrapper script around the GDAL/OGR `ogr2ogr` command line utility. To rename attributes, supply the following positional arguments:

- `<input_file>`: input file that needs attribute renaming
- `<output_gpkg>`: output GeoPackage with renamed attributes
- `<mapping>`: mapping file with each line containing: `${old_attribute_name}\t${new_attribute_name}`, see the example folder. Every attribute of the input file needs to mapped, otherwise the attribute will be omitted in the output GeoPackage
- `<layer_name>`: target layer in the input file
- `<optional:ogr-arguments>`: pass optional arguments for ogr2ogr, for example set the new layer name in the output GeoPackage `-nln new_layer_name`

For example:

```
./map-attributes.sh /vsizip/example/sample_shape.zip sample_shape sample.gpkg example/mapping.txt -nln new_layer_name
```

## Depedencies

Requires GDAL/OGR to be installed and the `ogr2ogr` command line utility needs to be available in the `$PATH` (environment variable), see [gdal.org](https://gdal.org/). 


## Usage

### Batch script (Windows)

```
map-attributes.bat /vsizip/example/CBS_PC4_2015_v2.zip CBS_PC4_2015_v2 CBS_PC4_2015_v2.gpkg --output-gpkg 
```

### Bash script (Linux)

```
./map-attributes.sh /vsizip/example/sample_shape.zip sample_shape sample.gpkg example/mapping.txt
```
