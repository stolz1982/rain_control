#!/bin/bash

#######################################################
# Autor: Steffen Stolz
# Mail: stolz1982@gmx.de
#
#
# Text: small script for handling/managing GPIOs of a
#       RaspianPi in order to control ventiles which
#	which are part of the system
#	Also, timer functions are necessary	
#
#######################################################

#######################################################
#
# GPIO Inputs and related Ventiles locations
# 17 = in front of the house
# 
#
#
#######################################################

#DEFINITION VARIABLES
LOG="/home/user01/skript/rain_control/RAIN.log"
ERR="/home/user01/skript/rain_control/RAIN.err"

#Initial deleting ERR File
rm $ERR

#Script Start
echo "################################################" >> $LOG
echo "#[START] RAIN SKRIPT" >> $LOG
echo "################################################" >> $LOG

#Turn of all connected GPIOS (in total 8 because of I am using an 8 channel relay)
for i in 17 18 27 22 23 24 10 9
do
 gpio -g write $i 1
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

#set gpio input status = 0 which opens the appropriate ventile
/usr/local/bin/gpio -g write $1 0

#Waiting the entered time period before closing ventile
sleep $2

#Turn off GPIO Input
/usr/local/bin/gpio -g write $1 1

 echo `date +%Y%m%d-%H%M%S`": GPIO Input $1 - STATUS: $(/usr/local/bin/gpio -g read $1)" >> $LOG


#Script End
echo "################################################" >> $LOG
echo "#[END] RAIN SKRIPT" >> $LOG
echo "################################################" >> $LOG

