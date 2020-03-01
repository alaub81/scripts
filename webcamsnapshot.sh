#!/bin/bash
#########################################################################
#Name: webcamsnapshot.sh
#Subscription: This script fetches the weather from yahoo, makes a snapshot of a webcam picture
#and combines the weather forecast with the snapshot picture.
#It may also integrate a temparture sensor output to the webcampicture
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
LOCATION=GMXX1081
WEATHER=/tmp/weatherforecast.txt
WEATHERBIN=/srv/python-yahoo-weather/weather.py
SENSOR=$(echo "scale=2; $(grep 't=' /sys/bus/w1/devices/w1_bus_master1/28-000004118a7f/w1_slave | awk -F't=' '{print $2}')/1000" | bc -l)
CAMPIC="/tmp/webcam.jpg"
LOGFILE="/var/log/webcamsnapshot.log"

#Remote Webserver (copy the picture via scp to the webserver)
ENABLEWEBSERVER="yes"   # yes or no
WEBSERVER="webserver.domain.de"
USER="root"
WEBHOME="/srv/httpd/vhosts/www.domain.de/htdocs/"

# Fetch the weather
$WEATHERBIN -mlvf2 GMXX1081 | sed 's/^[ \t]*//;s/[ \t]*$//;s/\([0-9]\{1,3\}\)C/\1°C/g' > $WEATHER

CURRENTCOND=$(sed -n '5p' $WEATHER)
DATE1=$(sed -n '8p' $WEATHER | sed 's/[ \t]/./'|awk '{ print $1}')
HIGH1=$(sed -n '9p' $WEATHER | awk -F': ' '{ print $2 }')
LOW1=$(sed -n '10p' $WEATHER | awk -F': ' '{ print $2 }')
COND1=$(sed -n '11p' $WEATHER | awk -F': ' '{ print $2 }')
DATE2=$(sed -n '12p' $WEATHER | sed 's/[ \t]/./'|awk '{ print $1}')
HIGH2=$(sed -n '13p' $WEATHER | awk -F': ' '{ print $2 }')
LOW2=$(sed -n '14p' $WEATHER | awk -F': ' '{ print $2 }')
COND2=$(sed -n '15p' $WEATHER | awk -F': ' '{ print $2 }')

# Weatherforecast text
WEATHERTEXT="$DATE1: H:$HIGH1 L:$LOW1 $COND1  |  $DATE2: H:$HIGH2 L:$LOW2 $COND2"

# Text for the webcam picture
TITLE="Heddesheim: $CURRENTCOND"
SUBTITLE="$WEATHERTEXT"
TIMESTAMP="%Y-%m-%d %H:%M (%Z)"
INFO="current temperature: $SENSOR°C"

# do the things
# make the picture
function takepicture {
        fswebcam -s contrast=55% -D 3 -S 5 -F 20 -r 640x480 -d /dev/video0 -q --title "$TITLE" --subtitle "$SUBTITLE" --timestamp "$TIMESTAMP" --info "$INFO" --jpeg "-1" $CAMPIC > $LOGFILE 2>&1
}
takepicture
while [ -n "$(cat $LOGFILE | grep 'Corrupt JPEG data')" ]; do
        takepicture
done

# copy the picture to Webserver
if [ "$ENABLEWEBSERVER" == "yes" ]; then
        scp -q $CAMPIC $USER@$WEBSERVER:$WEBHOME
fi
