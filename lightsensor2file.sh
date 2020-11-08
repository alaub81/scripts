#!/usr/bin/env bash
#########################################################################
#Name: lightsensor2file.sh
#Subscription: This Script writes just the bh1750.py Output to a txt file
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
DATAFILE=/opt/openHAB/data/openhab/conf/scripts/lightsensor.txt

# read lightsensor
VALUE=$(/usr/local/sbin/bh1750.py)

if [ -z "$VALUE" ]; then
    echo "Value is empty"
else
    echo $VALUE > $DATAFILE
fi
