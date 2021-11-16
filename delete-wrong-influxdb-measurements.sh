#!/bin/bash
#########################################################################
#Name: delete-wrong-influxdb-measurements.sh
#Subscription: This Script deletes measurements in influxdb which are too high or too small.
#
#by A. Laub
#andreas[-at-]laub-home.de
#
#License:
#This program is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public License as published by the
#Free Software Foundation, either version 3 of the License, or (at your option)
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#or FITNESS FOR A PARTICULAR PURPOSE.
#########################################################################
#Set the language
export LANG="en_US.UTF-8"
#Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

#set the variables:

# InfluxDB Command
INFLUX="docker exec -ti openhab3_influxdb_1 influx"
# InfluxDB Host
INFLUXHOST=localhost
# influxdb Database
INFLUXDB=openhab_db
# influxdb measurement
INFLUXDBMEASUREMENT=LaubRaspi2DHT22_Humidity
# influxdb wrong value (<;>;=)
INFLUXDBWRONGVALUE="< 0"
#INFLUXDBWRONGVALUE="> 100"
#INFLUXDBWRONGVALUE="= 0"

# do the stuff
for i in $($INFLUX -host $INFLUXHOST -port '8086' -database $INFLUXDB -execute "select * from $INFLUXDBMEASUREMENT where value $INFLUXDBWRONGVALUE" | grep -i ^[0-9] | cut -d' ' -f1); do
        $INFLUX -host $INFLUXHOST -port '8086' -database $INFLUXDB -execute "delete from $INFLUXDBMEASUREMENT where time = $i"
        echo "deleting $i"
done
