#!/bin/bash

DATEI="/home/user01/skript/rain_control/WEATHER.DAT"

clean () {
var_str=$1
var_str=${var_str#*>}
var_str=${var_str%<*}
}


if [ -e $DATEI ]; then
clean $(sed -n '18{p;q}' $DATEI)
echo "06:00 Uhr Wetterzustand: $var_str"
clean $(sed -n '20{p;q}' $DATEI)
echo "06:00 Uhr Min. Temp.: $var_str°C"
clean $(sed -n '19{p;q}' $DATEI)
echo "06:00 Uhr Max. Temp.: $var_str°C"

clean $(sed -n '26{p;q}' $DATEI)
echo "11:00 Uhr Wetterzustand: $var_str"
clean $(sed -n '28{p;q}' $DATEI)
echo "11:00 Uhr Min. Temp.: $var_str°C"
clean $(sed -n '27{p;q}' $DATEI)
echo "11:00 Uhr Max. Temp.: $var_str°C"

clean $(sed -n '34{p;q}' $DATEI)
echo "17:00 Uhr Wetterzustand: $var_str"
clean $(sed -n '36{p;q}' $DATEI)
echo "17:00 Uhr Min. Temp.: $var_str°C"
clean $(sed -n '35{p;q}' $DATEI)
echo "17:00 Uhr Max. Temp.: $var_str°C"

clean $(sed -n '42{p;q}' $DATEI)
echo "23:00 Uhr Wetterzustand: $var_str"
clean $(sed -n '44{p;q}' $DATEI)
echo "23:00 Uhr Min. Temp.: $var_str°C"
clean $(sed -n '43{p;q}' $DATEI)
echo "23:00 Uhr Max. Temp.: $var_str°C"

fi

