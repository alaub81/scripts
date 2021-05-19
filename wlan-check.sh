#!/usr/bin/env bash
#########################################################################
#Name: wlan-check.sh
#Subscription: This Script does a inerface restart, 
#if the gateway is not reachable
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

GATEWAY="192.168.50.1"
NETWORKINTERFACE="wlan0"

### Do the stuff
ping -w 30 -c 1 $GATEWAY > /dev/null 2>&1
if [ $? -ne 0 ]; then
        echo "Restart $NETWORKINTERFACE"
        ip link set $NETWORKINTERFACE down
        ip link set $NETWORKINTERFACE up
        # deprecated
        #ifdown $NETWORKINTERFACE
        #ifup $NETWORKINTERFACE
fi

