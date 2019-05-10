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
# Input parameters
# -V|--ventile = ventile which is the gpio port
# -t|--time = the time of raining period in seconds
# -n|--noforecast = forecast will be not considered, CONSIDERING_WEATHERFORECAST=0
# -h|--history-only = execute the sql command in order to build the history, WEATHER_HISTORY_ONLY=1
# -m|--max = if the forecasted max temp will excedds entered temperature then raining will be considered
# -r|--refill = if this option is entered it is necessary to provide 2 options (Ventile and time)
# 
#######################################################

#######################################################
#
# exit codes
# 0 = as usuaul everything is fine
# 1 = check
# 2 = no config file exist
# 99 = everything is fine and just build the weather forecast history
# 100 = no raining due to a lot of rain within the last 8 hours
# 101 = no raining due to maximum forecast temperature of less than 16 degrees
# 102 = no raining due to option -m // --max temperature and forecasted max temperature is less
# 103 = mysql connection 
#######################################################

#DEFINITION VARIABLES
CONFIG_FILE="/home/user01/rain_control/rain_control.cfg"

#Settings Defaults
RAIN_PERIODE=60
GPIO=0
#necessary parameter which don't start raining otherwise the grass will be burned
MAX_ENTERED_TEMP=36
BREAK_TEMP=14
min_temp=-99
max_temp=-99

if [ -e "$CONFIG_FILE" ]
then
. $CONFIG_FILE
else
exit 2
fi

if [ ! -d "$LOG_DIR" ]
then
mkdir $LOG_DIR
fi


# Read the options
TEMP=`getopt -o nhV:t:m:r: --long ventile:,noforecast,historyonly,time:,max:,refill: -n 'rain_getopt.sh' -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
while true ; do
case "$1" in
-n|--noforecast) CONSIDERING_WEATHERFORECAST=0 ; shift ;;
-h|--historyonly) WEATHER_HISTORY_ONLY=1 ; shift ;;
-V|--ventile)
case "$2" in
"") shift 2 ;;
*) GPIO=$2 ; shift 2 ;;
esac ;;
-t|--time)
case "$2" in
"") shift 2 ;;
*) RAIN_PERIODE=$2 ; shift 2 ;;
esac ;;
#if forecasted temperature exceeds temperature forecasted temperature the sprinkling will be start 
-m|--max)
case "$2" in
"") shift 2 ;;

*) MAX_ENTERED_TEMP=$2 ; shift 2 ;;
esac ;;


#refill option needs two inputs: 1. Ventile, 2. time
#example: ./rain_control.sh -V 18 -m 25 -r 19 20
#this option can refill tanks or what else in one command including refill ventile and refill time 
-r|--refill)
case "$2" in
"") shift 2 ;;
*) REFILL=1 ; REFILL_VENTILE=$2 ; shift ; REFILL_TIME=$1 , shift ;;
esac ;;

--) shift ; break ;;
*) echo "Internal error!" ; exit 1 ;;
esac
done

#further variables definition based on input parameters
LOG="$LOG_DIR/RAIN_$GPIO.log"

#Script Start
echo "################################################" | tee -a $LOG
echo "#[START] RAIN SKRIPT" | tee -a -a $LOG
echo "################################################" | tee -a $LOG


echo `date +%Y%m%d-%H%M%S`": CONFIGFILE=$CONFIG_FILE" | tee -a $LOG
echo `date +%Y%m%d-%H%M%S`": LOGDIR=$LOG_DIR" | tee -a $LOG
echo `date +%Y%m%d-%H%M%S`": LOGFILE=$LOG" | tee -a $LOG


#checking the internet connectivity
wget -q --spider http://google.com

if [ $? -eq 0 ]; then
echo `date +%Y%m%d-%H%M%S`": Internet connectivity available" | tee -a $LOG
INTERNET_CONN=TRUE
else
echo `date +%Y%m%d-%H%M%S`": Internet connectivity NOT available" | tee -a $LOG
INTERNET_CONN=FALSE
fi




#if CONSIDERING_WEATHERFORECAST=0 then no need to download and process forecast and the appropriate files
if [ $CONSIDERING_WEATHERFORECAST -ne 0 ]; then


#Initial deleting File
rm -f ./$FORECAST_FILE

#Getting weather forecast data
echo `date +%Y%m%d-%H%M%S`": START to get $FORECAST_FILE" | tee -a $LOG
wget $FC -O ./$FORECAST_FILE 1>/dev/null 2>&1

if [ $? -eq 0 ]; then
echo `date +%Y%m%d-%H%M%S`": FINISHED to get $FORECAST_FILE" | tee -a $LOG
else
echo `date +%Y%m%d-%H%M%S`": ERROR during trying to get $FORECAST_FILE" | tee -a $LOG
fi

echo `date +%Y%m%d-%H%M%S`": Start of string processing" | tee -a $LOG

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
}


merge () {
	clean $1
		translate $var_str
}

echo `date +%Y%m%d-%H%M%S`": END of string processing" | tee -a $LOG




echo `date +%Y%m%d-%H%M%S`": START of weather forecast processing" | tee -a $LOG
if [ -e $FORECAST_FILE ]; then

H=$(date +%H)
	if [ 3 -le $H ] && [ $H -lt 11 ]; then 
#06:00 a.m. weather 
	merge $(sed -n '22{p;q}' $FORECAST_FILE)
	clean $(sed -n '23{p;q}' $FORECAST_FILE)
	max_temp=$var_str
	clean $(sed -n '24{p;q}' $FORECAST_FILE)
	min_temp=$var_str
	elif [ 11 -le $H ] && [ $H -lt 17 ]; then 
#11:00 a.m.
	merge $(sed -n '30{p;q}' $FORECAST_FILE)
	clean $(sed -n '31{p;q}' $FORECAST_FILE)
	max_temp=$var_str
	clean $(sed -n '32{p;q}' $FORECAST_FILE)
	min_temp=$var_str
	elif [ 17 -le $H ] && [ $H -lt 23 ]; then
#5 p.m.
	merge $(sed -n '38{p;q}' $FORECAST_FILE)
	clean $(sed -n '39{p;q}' $FORECAST_FILE)
	max_temp=$var_str
	clean $(sed -n '40{p;q}' $FORECAST_FILE)
	min_temp=$var_str
	else
#11 p.m.
	merge $(sed -n '46{p;q}' $FORECAST_FILE)
	clean $(sed -n '47{p;q}' $FORECAST_FILE)
	max_temp=$var_str
	clean $(sed -n '48{p;q}' $FORECAST_FILE)
	min_temp=$var_str
	fi
	fi
	echo `date +%Y%m%d-%H%M%S`": END of weather forecast processing" | tee -a $LOG

#check if temperatures are zero/empty otherwise mysql brings an error
	if [ -z $min_temp ] || [ ! "$min_temp" ]; then
	min_temp=-99
	fi

	if [ -z $max_temp ] || [ ! "$max_temp" ]; then
	max_temp=-99
	fi


	echo `date +%Y%m%d-%H%M%S`": START of DB writing" | tee -a $LOG
#here starts the db writing history function 
# store the weather forecast data (pls see on top the parameter description) 

#building weather forecast history
	mysql -h $DB_SERVER_IP -u$DB_USER -p$DB_PWD -D $DATABASE_NAME -e "INSERT INTO wetterbericht set wetter_beschreibung = '$var_str_txt', temperatur_min = $min_temp , temperatur_max = $max_temp , beregnung=$var_rain;"

	if [ $? -ne 0 ]; then
	echo `date +%Y%m%d-%H%M%S`": EXIT of DB writing due to STATUS: $?. Script stopped with exit code 1" | tee -a $LOG
	exit 1
	else
	echo `date +%Y%m%d-%H%M%S`": END of DB writing, STATUS: $?" | tee -a $LOG
	fi

	if [ $WEATHER_HISTORY_ONLY -eq 1 ]; then
#error codes you can find on top
	echo `date +%Y%m%d-%H%M%S`": Script stopped with exit code 99 because of WEATHER HISTORY only" | tee -a $LOG
	exit 99
	fi


#here ends the clause of NO_WEATHER_FORECAST
	fi

#firstly, check whether parameters has been entered
	if [ -n "$GPIO" ]
	then
	echo `date +%Y%m%d-%H%M%S`": You have entered GPIO $GPIO Input" | tee -a $LOG
	else 
	echo `date +%Y%m%d-%H%M%S`": You haven't entered a GPIO# input" | tee -a $LOG
	exit 1
	fi

	if [ -n "$RAIN_PERIODE" ]
	then
	echo `date +%Y%m%d-%H%M%S`": You have entered raintime period in seconds: $RAIN_PERIODE" | tee -a $LOG
	else
	echo `date +%Y%m%d-%H%M%S`": You haven't entered a raintime period" | tee -a $LOG
	exit 2
	fi

	if [ $CONSIDERING_WEATHERFORECAST -eq 0 ]
	then   
	echo `date +%Y%m%d-%H%M%S`": weather forecast will not be considered: CONSIDERING_WEATHERFORECAST = $CONSIDERING_WEATHERFORECAST and variable var_rain will be set to 1" | tee -a $LOG
#not considering weather forecast just sets variable var_rain to 1 (open) 
	var_rain=1
	else
	echo `date +%Y%m%d-%H%M%S`": weather forecast will be considered: CONSIDERING_WEATHERFORECAST = $CONSIDERING_WEATHERFORECAST" | tee -a $LOG

#reviewing weatherdata for last 8 hours, if the avg of raining is = 1 then script will continue 
	rain_avg=$(mysql --connect-timeout=10 -h $DB_SERVER_IP -u $DB_USER -p$DB_PWD -D $DATABASE_NAME -Nse "select round(avg(beregnung)) from wetterbericht where zeitstempel > DATE_SUB(NOW(),INTERVAL 8 HOUR);")

#if the mysql query didn't work properly then the variable ran_avg will be set to 1
	if [ "$?" -ne "0" ]; then
	rain_avg=1
	fi

	if [ "$rain_avg" -lt 1 ]; then
	echo `date +%Y%m%d-%H%M%S`": No raining due to a lot of rain within last 8 hours: $rain_avg" | tee -a $LOG
	echo `date +%Y%m%d-%H%M%S`": Script exit with code 100" | tee -a $LOG
	exit 100
	fi

	if [ $max_temp -lt $BREAK_TEMP ]; then
	echo `date +%Y%m%d-%H%M%S`": No raining due to temperatur less than $BREAK_TEMP °C degrees: $max_temp °C" | tee -a $LOG
	echo `date +%Y%m%d-%H%M%S`": Script exit with code 101" | tee -a $LOG
	exit 101
	fi
	fi

	if [  $max_temp -gt $MAX_ENTERED_TEMP ]
	then
	echo `date +%Y%m%d-%H%M%S`": No Raining due to Forescasted maximum temperature ($max_temp °C) less than entered temperature ($MAX_ENTERED_TEMP °C)" | tee -a $LOG
	echo `date +%Y%m%d-%H%M%S`": Script exit with code 102" | tee -a $LOG
	exit 102
	else
	echo `date +%Y%m%d-%H%M%S`": Raining due to entered temperature($MAX_ENTERED_TEMP °C) greater than forcecasted maximum temperature ($max_temp °C)" | tee -a $LOG
	fi

#Turn off all possible GPIOS
#Security Feature
	echo `date +%Y%m%d-%H%M%S`": START of closing of all GPIOs" | tee -a $LOG
	i=1
	until [ $i -gt 30 ] 
	do
	$CMD_DIR/gpio export $i out && $CMD_DIR/gpio -g write $i 1
	echo `date +%Y%m%d-%H%M%S`": GPIO $i has been set to 1, STATUS: $?" | tee -a $LOG
i=$(( i+1 ))
	done
	echo `date +%Y%m%d-%H%M%S`": END of closing of all GPIOs, STATUS: $?" | tee -a $LOG


	echo `date +%Y%m%d-%H%M%S`": START of calling function raining" | tee -a $LOG
#call function raining
#raining()
	echo `date +%Y%m%d-%H%M%S`": END of function raining, STATUS: $?" | tee -a $LOG


	echo `date +%Y%m%d-%H%M%S`": [RAINING] - function started" | tee -a $LOG
	if [ $var_rain -eq 1 ]; then
#set gpio input status = 0 which opens the appropriate ventile
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - VAR_RAIN: $var_rain, STATUS: $?" | tee -a $LOG
	$CMD_DIR/gpio -g write $GPIO 0
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - starts because forecasted weather: $var_str_txt" | tee -a $LOG
#Waiting the entered time period before closing ventile
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - sleeping for $RAIN_PERIODE seconds" | tee -a $LOG
	sleep $RAIN_PERIODE 
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - slept for $RAIN_PERIODE seconds" | tee -a $LOG

#Turn off GPIO Input
	$CMD_DIR/gpio -g write $GPIO 1
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - GPIO Input $GPIO - GPIOSTATUS: $($CMD_DIR/gpio -g read $GPIO), STATUS(function): $?" | tee -a $LOG
	else
	echo `date +%Y%m%d-%H%M%S`": [RAINING] - No Raining (var_rain: $var_rain - var_input_str: $var_input_str) due to forecasted weather: $var_str_txt - STATUS: $?" | tee -a $LOG
	fi

#REFILL SECTION
	if [ -z $REFILL ] || [ ! "$REFILL" ] || [ $REFILL -eq 0 ]; then
	echo `date +%Y%m%d-%H%M%S`": [REFILL] - No Refill: $REFILL - STATUS: $?" | tee -a $LOG
	else
	echo `date +%Y%m%d-%H%M%S`": [REFILL] - Refilling: $REFILL - VENTILE: $REFILL_VENTILE - TIME: $REFILL_TIME" | tee -a $LOG
	/bin/bash $WORK_DIR/$0 -V $REFILL_VENTILE -t $REFILL_TIME -n
	fi

	echo "################################################" | tee -a $LOG
	echo "#[END] RAIN SKRIPT" | tee -a $LOG
	echo "################################################" | tee -a $LOG
