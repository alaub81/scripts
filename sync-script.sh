#!/bin/bash
# sync-script.sh
# Syncs Folder a to B
# by A.Laub andreas[-at-]laub-home.de

#Sync Path
#WARNING: No / at end of path
SYNCPATH="/srv"

#Exclude Files (for every exclude you need --exclude: "--exclude *.jpg --exclude *.txt)
#EXCLUDE="--exclude *.tc"

#Sync Target
#for Rsync over SSH: Backup path on target system
SYNCTARGET="/srv"

#User
RSUSER="root"

#Target Host
RSTARGET="192.168.0.2"


/usr/bin/rsync --delete -avz --progress --partial --inplace $EXCLUDE $SYNCPATH $RSUSER@$RSTARGET:$SYNCTARGET
