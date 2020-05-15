#!/usr/bin/env bash
#########################################################################
#Name: tempsensor2file.sh
#Subscription: This Script writes just the Adafruit Output to a txt file
#to a backup directory
##by A. Laub
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
# set the variables
# where to log data
DATAFILE=/opt/openHAB/data/openhab/conf/scripts/tempsensor.txt

# read Temp with Adafruit
VALUE=$(/opt/Adafruit_Python_DHT/examples/AdafruitDHT.py 22 2)

if [ -z "$VALUE" ]; then
    echo "Value is empty"
else
    echo $VALUE > $DATAFILE
fi
