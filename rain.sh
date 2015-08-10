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

#Turn of all connected GPIOS (in total 8 because of I am using an 8 channel relay)
for i in 17 17 17 17 17 17 17 17
 do
 gpio -g write i 1
 echo "GPIO $i - $(gpio -g read $i)"
done

#Turn on specific GPIOs which is parameter 1 for a timeperiod x which is parameter 2
# firstly, check whether parameters are entered
 if [ -n "$1" ]; then
   echo "You have no GPIO Input entered."
#   exit 1;
 fi


