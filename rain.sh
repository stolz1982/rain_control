#!/bin/bash

#######################################################
# Autor: Steffen Stolz
# Mail: stolz1982@gmx.de
#
#
# Text: small script for handling/managing GPIOs of a
#       RaspianPi in order to control ventiles which
#	which are part of the system
#	Also, timer functions are necessary and 
#	weather forecast data powered by wetter.com
#       http://www.wetter.com	
#
#######################################################

#######################################################
#
# GPIO Inputs and related Ventiles locations
# 17 = in front of the house and path to the garage
# 18 = flowers bed beyond the house
# 27 = first part of the mid field
# 22 = upper right part of the mid field
# 23 = upper left part of the mid field
#
#######################################################

#######################################################
#
# Input parameters
# 1 = GPIO Input
# 2 = time of rain duration in seconds
# 3 = considering weather forecast (1=yes 0=no)
# 4 = building weatherforecast history in DB (1= just build history and exit, else build history and contiune script)
#
#######################################################

#######################################################
#
# exit codes
# 0 = as usuaul everything is fine
# 99 = everthing is fine and just build the weather forecast history
# 100 = no raining due to a lot of rain within the last 8 hours
#
#######################################################

#DEFINITION VARIABLES
LOG="/home/user01/skript/rain_control/RAIN_$1.log"
ERR="/home/user01/skript/rain_control/RAIN_$1.err"
DATEI="/home/user01/skript/rain_control/WEATHER.DAT"
FC="http://api.wetter.com/forecast/weather/city/DE0007167/project/rain/cs/ca5ad911fabd64827d48cf0ab869dc76"
DB_SERVER_IP="192.168.2.202"
DB_USER="temperatur"

#Initial deleting Files
rm -f $ERR
rm -f $DATEI

#Getting weather forecast data for my hometown
wget $FC -O $DATEI 1>/dev/null 2>&1

#Functions for string processing
clean () {
var_str=$1
var_str=${var_str#*>}
var_str=${var_str%<*}
}

#translate is a function to define whether or not raining will take place which depends on
#on weathercode. provided by a list from wetter.com 
translate () {
var_str_txt=""
var_input_str=""
var_rain=0  #beduetet keine Beregnung
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
var_input_str=$1
}

merge () {
clean $1
translate $var_str
}


if [ -e $DATEI ]; then

H=$(date +%H)
if [ 3 -le $H ] && [ $H -lt 11 ]; then 
 #06:00 a.m. weather 
 merge $(sed -n '18{p;q}' $DATEI)
elif [ 11 -le $H ] && [ $H -lt 17 ]; then 
 #11:00 a.m.
 merge $(sed -n '26{p;q}' $DATEI)
elif [ 17 -le $H ] && [ $H -lt 23 ]; then
 #5 p.m.
 merge $(sed -n '34{p;q}' $DATEI)
else
 #11 p.m.
 merge $(sed -n '42{p;q}' $DATEI)
fi
fi

#here starts the db writing history function, if the 4. parameter equal 1, it means the script should just 
# store the weather forecast data (pls see on top the parameter description) 
# 4th parameter ($4 = 1 --> just store and exit, else store and continue)

#building weather forecast history
#hier wird es fortgestzt
mysql -h $DB_SERVER_IP -u $DB_USER -p$DB_USER -D home -e "INSERT INTO wetterbericht set wetter_beschreibung = '$var_str_txt', temperatur=0,beregnung=$var_rain;"

if [ $? -ne 0 ]; then
exit 1
fi

if [ $4 -eq 1 ]; then
#error codes you can find on top
exit 99
fi

#Script Start
echo "################################################" >> $LOG
echo "#[START] RAIN SKRIPT" >> $LOG
echo "################################################" >> $LOG

#Turn off all connected GPIOS (in total 8 because of I am using an 8 channel relay)
for i in 17 18 27 22 23 24 10 9
do
/usr/local/bin/gpio export $i out && /usr/local/bin/gpio -g write $i 1
now=`date +%Y%m%d-%H%M%S`
echo $now": GPIO Input $i - STATUS: $(/usr/local/bin/gpio -g read $i)" >> $LOG
done

#firstly, check whether parameters has been entered
if [ -n "$1" ]
   then
    echo `date +%Y%m%d-%H%M%S`": You have entered GPIO $1 Input" >> $LOG
   else 
    echo `date +%Y%m%d-%H%M%S`": You haven't entered a GPIO# input" >> $ERR
    exit 1
fi

if [ -n "$2" ]
   then
    echo `date +%Y%m%d-%H%M%S`": You have entered raintime period in seconds: $2" >> $LOG
   else
    echo `date +%Y%m%d-%H%M%S`": You haven't entered a raintime period" >> $ERR
     exit 2
fi

if [ $3 -eq 0 ]
    then   
      echo `date +%Y%m%d-%H%M%S`": weather forecast will not be considered: $3 and variable var_rain will be set to 1" >> $LOG
      #not considering weather forecast just sets variable var_rain to 1 (open) 
      var_rain=1
    else
     echo `date +%Y%m%d-%H%M%S`": weather forecast will be considered: $3" >> $LOG
fi

#reviewing weatherdata for last 8 hours, if the avg of raining is = 1 then script will continue 
rain_avg=$(mysql -h $DB_SERVER_IP -u $DB_USER -p$DB_USER -D home -se "select round(avg(beregnung)) from wetterbericht where zeitstempel > DATE_SUB(NOW(),INTERVAL 8 HOUR);")

if [ $rain_avg -lt 1 ]; then
	echo `date +%Y%m%d-%H%M%S`": No raining due to a lot of rain within last 8 hours: $rain_avg" >> $LOG
	echo `date +%Y%m%d-%H%M%S`": Script exit with code 100" >> $LOG
	exit 100
fi

if [ $var_rain -eq 1 ]; then
#set gpio input status = 0 which opens the appropriate ventile
/usr/local/bin/gpio -g write $1 0
echo `date +%Y%m%d-%H%M%S`": Raining due to $var_str_txt" >> $LOG
#Waiting the entered time period before closing ventile
 sleep $2

 #Turn off GPIO Input
 /usr/local/bin/gpio -g write $1 1

 echo `date +%Y%m%d-%H%M%S`": GPIO Input $1 - STATUS: $(/usr/local/bin/gpio -g read $1)" >> $LOG
else
 echo `date +%Y%m%d-%H%M%S`": No Raining (var_rain: $var_rain - var_input_str: $var_input_str) due to forecasted weather: $var_str_txt" >> $LOG
fi

#Script End
echo "################################################" >> $LOG
echo "#[END] RAIN SKRIPT" >> $LOG
echo "################################################" >> $LOG

