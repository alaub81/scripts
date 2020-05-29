#!/bin/bash
#########################################################################
#Name: cleanup-openhab-influxdb.sh
#Subscription: This Script deletes unused item entrys in the influxdb
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

# Tempfolder
TMPDIR=/tmp/
# openHAB Server
OPENHABSERVER=localhost

# InfluxDB Command
INFLUX="docker exec -ti openhab_influxdb_1 influx"
# InfluxDB Host
INFLUXHOST=localhost
# openHAB Database
INFLUXDB=openhab_db

# do the stuff
# generate Items list
curl -s -k -X GET --header "Accept: application/json" "https://$OPENHABSERVER:8443/rest/items?recursive=false&fields=name" | sed 's/,/\n/g' | awk -F '"' '{ print $4}' | sort -n > $TMPDIR/items.txt

# read Measurements from InfluxDB
$INFLUX -host $INFLUXHOST -port '8086' -database $INFLUXDB -execute 'show measurements' | tail +4 | sort -n > $TMPDIR/measurements.txt


for i in $(diff -Zu $TMPDIR/items.txt $TMPDIR/measurements.txt | grep -i ^+[a-z,0-9] | cut -d '+' -f 2); do
	$INFLUX -host $INFLUXHOST -port '8086' -database $INFLUXDB -execute "drop measurement $i"
	echo delete measurement: $i
done


rm $TMPDIR/items.txt
rm $TMPDIR/measurements.txt
