#!/bin/bash
#########################################################################
#Name: digitalstrom_binding_tools.sh
#Subscription: This Script tries to get the things with the openHAB digitalstrom
#              binding more stable
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

#openHAB URL
OPENHAB=https://localhost:8443

#digitalSTROM Things UID (%3A is :)
#digitalSTROM Bridge
BRIDGE=digitalstrom:dssBridge:eb907aa7
#digitalSTROM Rolladen
ROLLO=digitalstrom%3AGR%3Aeb907aa7%3A303505d7f8000f00000fb6e7
#digitalSTROM Stromverbrauch
WATT=digitalstrom%3Acircuit%3Aeb907aa7%3A302ed89f43f00e400000cc38
#digitalSTROM ALL Group for refresh the Sensor Status
ALL=Rolladen_ALL

# IP of the Digitalstrom Server
DSS=192.168.50.100

# logfile options
# Lines displayed in the output
NUMBER=30
# Where is the openhab.log
LOGFILE=/var/lib/docker/volumes/openhab_data_openhab_userdata/_data/logs/openhab.log

#do the things
function getstatus {
	FULLSTATUSBRIDGE=$(curl -s -k -X GET --header "Accept: application/json" "$OPENHAB/rest/things/$BRIDGE/status")
	FULLSTATUSROLLO=$(curl -s -k -X GET --header "Accept: application/json" "$OPENHAB/rest/things/$ROLLO/status")
	FULLSTATUSWATT=$(curl -s -k -X GET --header "Accept: application/json" "$OPENHAB/rest/things/$WATT/status")
	STATUSBRIDGE=$(echo $FULLSTATUSBRIDGE | cut -d":" -f2 | cut -d"," -f1 | cut -d'"' -f2)
	STATUSROLLO=$(echo $FULLSTATUSROLLO | cut -d":" -f2 | cut -d"," -f1 | cut -d'"' -f2)
	STATUSWATT=$(echo $FULLSTATUSWATT | cut -d":" -f2 | cut -d"," -f1 | cut -d'"' -f2)
}

function status {
	echo "Bridge Status: $STATUSBRIDGE"
	echo "Rolladen Status: $STATUSROLLO"
	echo "Verbrauch Status: $STATUSWATT"
}

function fullstatus {
	echo "Bridge Fullstatus: $FULLSTATUSBRIDGE"
	echo "Rolladen Fullstatus: $FULLSTATUSROLLO"
	echo "Verbrauch Fullstatus: $FULLSTATUSWATT"
}

function refresh {
	curl -s -k -X POST --header "Content-Type: text/plain" --header "Accept: application/json" -d "REFRESH" "$OPENHAB/rest/items/$ALL"
	echo "Refresh Done!"
}

function restart {
	echo "Restarting $BRIDGE"
        curl -s -k -X PUT --header "Content-Type: application/json" --header "Accept: application/json" -d "false" "$OPENHAB/rest/things/$BRIDGE/enable" > /dev/null
        curl -s -k -X PUT --header "Content-Type: application/json" --header "Accept: application/json" -d "true" "$OPENHAB/rest/things/$BRIDGE/enable" > /dev/null
}

function autorestart {
	if [ "$STATUSBRIDGE" != "ONLINE" ] || [ "$STATUSROLLO" != "ONLINE" ] || [ "$STATUSWATT" != "ONLINE" ]; then
		echo "status is not Online!"
		echo "-------------------------------------"
		fullstatus
		echo -e "\nConnection Test"
		echo "-------------------------------------"
		ping -q -c 5 $DSS
		echo -e "\nlast $NUMBER line of $LOGFILE"
		echo "-------------------------------------"
		tail -n $NUMBER $LOGFILE
		echo " "
		restart
		echo "-------------------------------------"
		sleep  10
		echo -e "\n after restart"
		echo "last $NUMBER line of $LOGFILE"
		echo "-------------------------------------"
		tail -n $NUMBER $LOGFILE
		getstatus
		if [ "$STATUSBRIDGE" != "ONLINE" ] || [ "$STATUSROLLO" != "ONLINE" ] || [ "$STATUSWATT" != "ONLINE" ]; then
			echo -e "\nRestart didn't work Bridge Status!"
			echo "-------------------------------------"
			fullstatus
		elif [ "$NEWSTATUS" = "ONLINE" ]; then
			refresh
			echo "\n refreshing Item Status "
			echo "-------------------------------------"
		fi
	fi
}

case "$1" in
        status)
		getstatus
                status
                ;;
        fullstatus)
		getstatus
                status
                fullstatus
                ;;
        restart)
                restart
                ;;
        autorestart)
		getstatus
                autorestart
                ;;
        refresh)
                refresh
                ;;
        *)
                echo "Usage: $0 { status | fullstatus | refresh | restart | autorestart }"
                exit 1
                ;;
esac

