#!/bin/bash

mysql -h 192.168.2.202 -u temperatur -ptemperatur -D home -e "INSERT INTO wetterbericht set wetter_beschreibung='bedeckt', temperatur_min=12 , temperatur_max=12 , beregnung=1;"
echo $(/usr/bin/mysql -h 192.168.2.202 -utemperatur -ptemperatur -v -D home -e "select count(*) as 'avgrain' from wetterbericht;")
