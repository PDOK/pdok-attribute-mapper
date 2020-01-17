@ECHO OFF

:loop
IF NOT "%1"=="" (
	IF "%1"=="--mapping" (
		SET MAPPING=%2
		SHIFT
		SHIFT
	)
	IF "%1"=="--input-file" (
		SET INPUT_FILE=%2
		SHIFT
		SHIFT
	)
	IF "%1"=="--layer-name" (
		SET LAYER_NAME=%2
		SHIFT
		SHIFT
	)
	IF "%1"=="--output-gpkg" (
		SET OUTPUT_GPKG=%2
		SHIFT
		SHIFT
	)
	IF "%1"=="--help" (
		call :print_usage
		GOTO :EOF
	)
	GOTO :loop
)

set "_attributes="
set count=0
SETLOCAL ENABLEDELAYEDEXPANSION
for /F "tokens=*" %%z in (%MAPPING%) do (
	for /F "tokens=1,2" %%a in ("%%z") do (
		rem old_val: %%a
		rem new_val: %%b
		IF "!count!" equ "0" (
			set "_attributes=%%a as %%b"
			set count=1
		) ELSE (
			set "_attributes=!_attributes!, %%a as %%b"
		)
	)
)
set "query=SELECT !_attributes! from %LAYER_NAME%"
ogr2ogr -f GPKG "%OUTPUT_GPKG%" "%INPUT_FILE%" -sql "!query!" -nln "%LAYER_NAME%"
echo.

if %ERRORLEVEL% EQU 0 (
	echo %~n0%~x0: ran succesfully
	GOTO :EOF
)
if %ERRORLEVEL% GEQ 1 (
	echo %~n0%~x0: error occured
	del /q %OUTPUT_GPKG% >nul 2>&1
	GOTO :EOF
)

GOTO :EOF

:print_usage 
echo Usage: %~n0%~x0 --input-file ^<input-file^> --layer-name ^<layer-name^> --output-gpkg ^<output-gpkg^> --mapping ^<mapping^>
echo.
echo --input-file ^<input-file^>        Input file; any file format that GDAL/OGR can read
echo.
echo --layer-name ^<layer-name^>        Layer name in input file
echo.
echo --output-gpkg ^<output-gpkg^>      Filepath of GeoPackage output
echo.
echo --mapping ^<mapping^>              Path to attribute mapping file
echo.
echo --help                           Print usage and exit
EXIT /B 0
