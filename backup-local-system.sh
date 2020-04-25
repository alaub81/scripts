#!/bin/bash
#########################################################################
#backup-local-system.sh
#Backup Script
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
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

#########################################################################
#Backup Options
#########################################################################
#where to save the backup files
BACKUPPATH="/backup/system"
#Temporary backup files path
BACKUPTEMPPATH="/tmp"
#Backup filenames
FULLBACKUPFILE="backup-$(date +"%F-%H%M")-FULL.tar.gz"
DIFFBACKUPFILE="backup-$(date +"%F-%H%M")-DIFF.tar.gz"
#What you want to backup
FILESTOSAVE="/root/ /etc/ /usr/local/sbin/ /srv/ /var/ /home/ /boot/ /media/"
#Files you want to exclude from the backup (uncomment to use)
EXCLUDEFILES="--exclude=/var/lib/docker/* --exclude=/var/cache/apt/* --exclude=/var/swap --exclude=/var/spool/postfix/*"
# Make only a Full Backups and No Differential (yes/no)
FULLBACKUPONLY="no"
# Day for the FullBackup (Sun,Mon,Tue,Wed,Thu,Fri,Sat)
FULLBACKUPDAY="Sun"
#Delete old Backupfiles when they are xx Days old
DAYS="14"

#########################################################################
#Logging Options
#########################################################################
#Mail Notification (yes/no)
STATUSMAIL="yes"
#Email Adress, where to send the logfile
MAILADRESS="andreas@laub-home.de"
#Logfile
LOGFILE="/var/log/systembackup.log"


##########################################################################
#Here the functions starting: Don't edit below
##########################################################################

function STARTBLABLA {
echo "#############################################	"                    		> $LOGFILE
echo "#  Local Backup            	 		"                         	>> $LOGFILE
echo "#  started: $(date +"%k:%M %d.%m.%Y")   		"                      		>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
}

function BACKUPDIRCHECK {
if [ -d $BACKUPPATH ]; then
	echo "Backup folder exists"							>> $LOGFILE
else
   	mkdir -p $BACKUPPATH
	echo "Backup folder created"							>> $LOGFILE
fi
}

function REMOVE {
#Remove old Backup files 
find $BACKUPPATH -iname "*.tar.gz" -daystart -mtime +$DAYS -delete	 		>> $LOGFILE
#Remove Timestamp File on Fullbackupday
if [ $(date +%a) = $FULLBACKUPDAY -o $FULLBACKUPONLY = yes ]; then
	rm -f $BACKUPPATH/timestamp.txt
fi
}

function PACKAGE {
#Backup Packagelist
#Help for restore:
#1. dpkg --set-selections < $BACKUPTEMPPATH/$BACKUPHOST_pkglist.txt
#2. dselect
echo "Packagelist Backup"								>> $LOGFILE
dpkg --get-selections > $BACKUPTEMPPATH/pkglist.txt

#Backup Package Answers
#Help for restore:
#1. debconf-set-selections $BACKUPPATH/$BACKUPHOST_pkganswers.tx
echo "Pakage Answers Backup"								>> $LOGFILE
debconf-get-selections > $BACKUPTEMPPATH/pkganswers.txt
#read OTHERBACKUPFILES
OTHERBACKUPFILES="$BACKUPTEMPPATH/pkglist.txt $BACKUPTEMPPATH/pkganswers.txt"
}

function FULLBACKUP {
echo "Full Backup:"									>> $LOGFILE
date '+%Y-%m-%d %H:%M:%S' > $BACKUPPATH/timestamp.txt
tar czPf $BACKUPPATH/$FULLBACKUPFILE $EXCLUDEFILES $FILESTOSAVE $OTHERBACKUPFILES \
	2> /tmp/tmp_file; grep "^tar:" /tmp/tmp_file | grep -v "file is unchanged" 	>> $LOGFILE
/bin/ls -lh $BACKUPPATH/$FULLBACKUPFILE | awk '{ print $5 " " $8 " " $9}'		>> $LOGFILE
}

function DIFFBACKUP {
#Timestamp Datei Auslesen
echo "Diff Backup:"									>> $LOGFILE
tar czPf $BACKUPPATH/$DIFFBACKUPFILE --newer $BACKUPPATH/timestamp.txt $EXCLUDEFILES $FILESTOSAVE $OTHERBACKUPFILES \
	2> /tmp/tmp_file; grep "^tar:" /tmp/tmp_file | grep -v "file is unchanged"	>> $LOGFILE
/bin/ls -lh $BACKUPPATH/$DIFFBACKUPFILE | awk '{ print $5 " " $8 " " $9}'		>> $LOGFILE
}

function CLEANUP {
rm -f $OTHERBACKUPFILES
}
function ENDBLABLA {
echo ""                                                                 		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
echo "#  Local Backup					"                      		>> $LOGFILE
echo "#  ended: $(date +"%k:%M %d.%m.%Y") 		"                      		>> $LOGFILE
echo "#  runtime: $RUNTIME				"				>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
}

function RUNNINGTIME {
# stop the timer ########################################
ende=$(date +%s)

diff=$[ende-anfang]
RUNTIME="Runtime: $[$diff / 60]min $[$diff % 60]s"
}

function MAIL {
mail -s "Local Backup on $(hostname -s)" $MAILADRESS 					< $LOGFILE
}


#####################################################################################
# All functions into 1 function :-)
#####################################################################################

function SYSTEMBACKUP {
# start timer ########################################
anfang=$(date +%s)

STARTBLABLA
BACKUPDIRCHECK
REMOVE
PACKAGE
if [ ! -f $BACKUPPATH/timestamp.txt ]; then 
	FULLBACKUP
elif [ -f $BACKUPPATH/timestamp.txt ]; then
	DIFFBACKUP
fi
CLEANUP
RUNNINGTIME
ENDBLABLA
if [ $STATUSMAIL = yes ]; then
    MAIL
fi
}

# at least start the backup
SYSTEMBACKUP
