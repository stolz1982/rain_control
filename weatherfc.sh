#!/bin/bash

DATEI="/home/user01/skript/rain_control/WEATHER.DAT"
FC="http://api.wetter.com/forecast/weather/city/DE0007167/project/rain/cs/ca5ad911fabd64827d48cf0ab869dc76"

#Initial deleting Files
rm -f $DATEI

#Getting weather forecast data for my hometown
wget $FC -O $DATEI 1>/dev/null 2>&1

clean () {
var_str=$1
var_str=${var_str#*>}
var_str=${var_str%<*}
}

translate () {
var_str_txt=""
var_rain=0 #beduetet keine Beregnung
case $1 in
0)
  var_str_txt='sonnig'
  var_rain=1
  ;;
1)
  var_str_txt='leicht bewoelkt'
  var_rain=1
  ;;
2)
  var_str_txt='wolkig'
  var_rain=1
  ;;
3)
  var_str_txt='bedeckt'
  var_rain=1
  ;;
4)
  var_str_txt='Nebel'
  var_rain=0
  ;;
5)
  var_str_txt='Sprühregen'
  var_rain=0
  ;;
6)
  var_str_txt='Regen'
  var_rain=0
  ;;
7)
  var_str_txt='Schauer'
  var_rain=0
  ;;
9)
  var_str_txt='Gewitter'
  var_rain=0
  ;;
10)
  var_str_txt='leicht bewölkt'
  var_rain=1
  ;;
20)
  var_str_txt='wolkig'
  var_rain=1
  ;;
30)
  var_str_txt='bedeckt'
  var_rain=1
  ;;
40)
  var_str_txt='Nebel'
  var_rain=0
  ;;
45)
  var_str_txt='Nebel'
  var_rain=0
  ;;
48)
  var_str_txt='Nebel mit Reifbildung'
  var_rain=0
  ;;
49)
  var_str_txt='Nebel mit Reifbildung'
  var_rain=0
  ;;
50)
  var_str_txt='Sprühregen'
  var_rain=0
  ;;
51)
  var_str_txt='leichter Spruehregen'
  var_rain=0
  ;;
53)
  var_str_txt='Sprühregen'
  var_rain=0
  ;;
55)
  var_str_txt='starker Sprühregen'
  var_rain=0
  ;;
56)
  var_str_txt='leichter Spruehregen, gefrierend'
  var_rain=0
  ;;
57)
  var_str_txt='starker Spruehregen, gefrierend'
  var_rain=0
  ;;
60)
  var_str_txt='leichter Regen'
  var_rain=0
  ;;
61)
  var_str_txt='leichter Regen'
  var_rain=0
  ;;
63)
  var_str_txt='maessiger Regen'
  var_rain=0
  ;;
65)
  var_str_txt='starker Regen'
  var_rain=0
  ;;
66)
  var_str_txt='leichter Regen, gefrierend'
  var_rain=0
  ;;
67)
  var_str_txt='maessiger Regen od. starker Regen, gefrierend'
  var_rain=0
  ;;
68)
  var_str_txt='leichter Schnee-Regen'
  var_rain=0
  ;;
69)
  var_str_txt='starker Schnee-Regen'
  var_rain=0
  ;;
70)
  var_str_txt='leichter Schneefall'
  var_rain=0
  ;;
71)
  var_str_txt='leichter Schneefall'
  var_rain=0
  ;;
73)
  var_str_txt='maessiger Schneefall'
  var_rain=0
  ;;
75)
  var_str_txt='starker Schneefall'
  var_rain=0
  ;;
80)
  var_str_txt='leichter Regen - Schauer'
  var_rain=0
  ;;
81)
  var_str_txt='Regen - Schauer'
  var_rain=0
  ;;
82)
  var_str_txt='starker Regen - Schauer'
  var_rain=0
  ;;
83)
  var_str_txt='leichter Schnee/Regen - Schauer'
  var_rain=0
  ;;
84)
  var_str_txt='starker Schnee/Regen - Schauer'
  var_rain=0
  ;;
85)
  var_str_txt='leichter Schnee/Regen - Schauer'
  var_rain=0
  ;;
86)
  var_str_txt='maessiger oder starker Schnee - Schauer'
  var_rain=0
  ;;
90)
  var_str_txt='Gewitter'
  var_rain=0
  ;;
95)
  var_str_txt='leichtes Gewitter'
  var_rain=0
  ;;
96)
  var_str_txt='starkes Gewitter'
  var_rain=0
  ;;
999)
  var_str_txt='Keine Angabe'
  var_rain=0
  ;;
*)
  var_str_txt='neuer Status - Doku prüfen'
  var_rain=0
  ;;
esac
}

merge () {
clean $1
translate $var_str
}


if [ -e $DATEI ]; then

merge $(sed -n '18{p;q}' $DATEI)
output="06:00 Uhr $var_str_txt - " 
clean $(sed -n '20{p;q}' $DATEI)
output="$output $var_str°C/"
clean $(sed -n '19{p;q}' $DATEI)
output="$output$var_str°C"
echo $output

merge $(sed -n '26{p;q}' $DATEI)
output="11:00 Uhr $var_str_txt - " 
clean $(sed -n '28{p;q}' $DATEI)
output="$output $var_str°C/"
clean $(sed -n '27{p;q}' $DATEI)
output="$output$var_str°C"
echo $output

merge $(sed -n '34{p;q}' $DATEI)
output="17:00 Uhr $var_str_txt - " 
clean $(sed -n '36{p;q}' $DATEI)
output="$output $var_str°C/"
clean $(sed -n '35{p;q}' $DATEI)
output="$output$var_str°C"
echo $output

merge $(sed -n '42{p;q}' $DATEI)
output="23:00 Uhr $var_str_txt - " 
clean $(sed -n '44{p;q}' $DATEI)
output="$output $var_str°C/"
clean $(sed -n '43{p;q}' $DATEI)
output="$output$var_str°C"
echo $output

fi

