#!/bin/bash
# This Script logs the drive State Changes of an HDD using hdparm
# by A. Laub andreas[-at-]laub-home.de

#Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# HHD="/dev/sda /dev/sdb /dev/sdc"
HDD="/dev/sda /dev/sdb"
UTC=$(date +%s)
for i in $HDD; do
        DISK=$(echo "$i" | awk -F"/" '{ print $3 }')
        NOW=$(hdparm -C $i | grep "drive state" | awk '{ print $4 }')
        if [ -f /tmp/drivestate-$DISK ]; then
                LAST=$(cat /tmp/drivestate-$DISK)
                if [ $NOW != $LAST ]; then
                        echo "$NOW" > /tmp/drivestate-$DISK
                        echo "$(date +"%b %d %H:%M:%S") drivestate of $i changed to $NOW at $UTC" >> /var/log/drivestate
                fi
        else
                echo "$NOW" > /tmp/drivestate-$DISK
        fi
done
