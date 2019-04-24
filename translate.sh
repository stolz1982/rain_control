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
# exit codes
# 0 = as usuaul everything is fine
# 99 = reason not part of the translation
#######################################################

#translate is a function to define whether or not raining will take place which depends on
#on weathercode. provided by a list from wetter.com 
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
  exit 99
  ;;
esac

echo "$var_rain" "$var_str_txt"
