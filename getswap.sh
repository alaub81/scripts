#!/bin/bash
#########################################################################
#Name: getswap.sh
#Subscription: Get current swap usage for all running processes
#by A. Laub
#andreas[-at-]laub-home.de
#original Script from Erik Ljungstrom 27/05/2011
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

#do something:
function all {
	SUM=0
	OVERALL=0
	for DIR in $(find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"); do
        	PID=$(echo $DIR | cut -d / -f 3)
        	PROGNAME=$(ps -p $PID -o comm --no-headers)
                	for SWAP in $(grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'); do
                        let SUM=$SUM+$SWAP
                done
        	echo "PID=$PID - Swap used: $SUM - ($PROGNAME )"
        	let OVERALL=$OVERALL+$SUM
        	SUM=0
	done
echo "Overall swap used: $OVERALL"
}

case "$1" in
        all)
                all
                ;;
        mostused)
                all | sort -n -k 5
                ;;
        swaponly)
                all | egrep -v "Swap used: 0" |sort -n -k 5
                ;;
        *)
                echo "Usage: $0 { all | mostused | swaponly }"
                exit 1
                ;;
esac
