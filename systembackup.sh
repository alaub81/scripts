#!/bin/bash
#########################################################################
#systembackup.sh
#Backup Script
#by A. Laub
#andreas@laub-home.de
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
#Backup Configfile Options
#########################################################################
#You want to use configfiles instead of configuring the script for each host?
#(yes/no)
USECONFIGS="no"
#Where you want to store the configfiles
#(configfiles should end with .conf)?
CONFIGFILEPATH="/etc/systembackup"


#########################################################################
#Backup Options
#########################################################################
#Host which you want to backup
BACKUPHOST="vserver.laub-home.de"
#Backupuser on the Backuphost which can connect over ssh
BACKUPUSER="root"
#where to save the backup files
#BACKUPPATH="/srv/samba/Sicherung/$BACKUPHOST"
BACKUPPATH="/backup"
#Temporary backup files path
BACKUPTEMPPATH="/tmp"
#Backup filenames
FULLBACKUPFILE="$BACKUPHOST-$(date +"%F-%H%M")-FULL.tar.gz"
DIFFBACKUPFILE="$BACKUPHOST-$(date +"%F-%H%M")-DIFF.tar.gz"
#What you want to backup
FILESTOSAVE="/root/ /etc/ /srv/httpd /srv/php-exec /srv/php-tmp /srv/vmail /usr/local/sbin"
#Files you want to exclude from the backup
EXCLUDEFILES="--exclude "exclude.tar.gz""
# Make only a Full Backups and No Differential (yes/no)
FULLBACKUPONLY="no"
# Day for the FullBackup (Sun,Mon,Tue,Wed,Thu,Fri,Sat)
FULLBACKUPDAY="Sun"
#Delete old Backupfiles when they are xx Days old
DAYS="14"


########################################################################
#MySQL Options
########################################################################
#MySQL Backup active or not (yes/no)?
MYSQLACTIVE="yes"
#Which SQL Server you want to save?
MYSQLHOST="localhost"
#MySQL User (needs SELECT, SHOW DATABASES, LOCK TABLES, SHOW VIEW)
MYSQLUSER="backup"
#MySQL Password
PASSWORD="mfvxhCTxszeZsX6y"
#MySQL Backup File Name
MYSQLBACKUPFILE="$BACKUPHOST-$(date +"%F-%H%M")-MYSQL.sql"
#How long do you want to keep the MySQL Backup files
MYSQLDAYS="3"

#########################################################################
#Logging Options
#########################################################################
#Mail Notification (yes/no)
STATUSMAIL="yes"
#Email Adress, where to send the logfile
MAILADRESS="support@laub-home.de"
#Logfile
LOGFILE="/var/log/systembackup-$BACKUPHOST.log"
#Enable Nagios Monitoring (yes/no)
NAGIOSMONITORING="yes"
#Nagios logfile for check_backuplog.sh
NAGIOSLOGFILE="/var/log/check_systembackup-$BACKUPHOST.log"

##########################################################################
#Here the functions starting: Don't edit below
##########################################################################

function STARTBLABLA {
echo "#############################################	"                    		> $LOGFILE
echo "#  $BACKUPHOST Backup        	 		"                         	>> $LOGFILE
echo "#  started: $(date +"%k:%M %d.%m.%Y")   		"                      		>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
}

function BACKUPDIRCHECK {
if [ -d $BACKUPPATH ]; then
    echo "Backup folder exists"													>> $LOGFILE
else
   	mkdir -p $BACKUPPATH
	echo "Backup folder created"												>> $LOGFILE
fi
}

function REMOVE {
#Remove old Backup files 
find $BACKUPPATH/$BACKUPHOST*.tar.gz -daystart -mtime +$DAYS -delete	 		>> $LOGFILE
if [ $MYSQLACTIVE = yes ]; then
	find $BACKUPPATH/$BACKUPHOST*.sql.gz -daystart -mtime +$MYSQLDAYS -delete 	>> $LOGFILE
fi
DELETEERROR=$?
#Remove Timestamp File on Fullbackupday
if [ $(date +%a) = $FULLBACKUPDAY -o $FULLBACKUPONLY = yes ]; then
	rm -f $BACKUPPATH/$BACKUPHOST-timestamp.txt
fi
}

function PACKAGE {
#Backup Packagelist
#Help for restore:
#1. dpkg --set-selections < $BACKUPTEMPPATH/$BACKUPHOST_pkglist.txt
#2. dselect
echo "Packagelist Backup"														>> $LOGFILE
dpkg --get-selections > $BACKUPTEMPPATH/$BACKUPHOST-pkglist.txt	
PACKAGELISTERROR=$?

#Backup Package Answers
#Help for restore:
#1. debconf-set-selections $BACKUPPATH/$BACKUPHOST_pkganswers.tx
echo "Pakage Answers Backup"													>> $LOGFILE
debconf-get-selections --installer > $BACKUPTEMPPATH/$BACKUPHOST-pkganswers.txt
INSTALLERANSWERSERROR=$?
debconf-get-selections >> $BACKUPTEMPPATH/$BACKUPHOST-pkganswers.txt
PACKAGEANSWERSERROR=$?
#read OTHERBACKUPFILES
OTHERBACKUPFILES="$BACKUPTEMPPATH/$BACKUPHOST-pkglist.txt $BACKUPTEMPPATH/$BACKUPHOST-pkganswers.txt"
}

function MYSQL {
#Backup MySQL
#Help for restore:
#1. mysql < $BACKUPTEMPPATH/$BACKUPHOST_backup.sql
echo "MySQL Backup"																>> $LOGFILE
/usr/bin/mysqldump --user=$MYSQLUSER --password=$PASSWORD --host=$MYSQLHOST --all-databases > $BACKUPPATH/$MYSQLBACKUPFILE
MYSQLERROR=$?
gzip -f $BACKUPPATH/$MYSQLBACKUPFILE
GZIPERROR=$?
}

function FULLBACKUP {
echo "FULL: Backup Files"														>> $LOGFILE
date '+%Y-%m-%d' > $BACKUPPATH/$BACKUPHOST-timestamp.txt
tar czvf $BACKUPPATH/$FULLBACKUPFILE $FILESTOSAVE $OTHERBACKUPFILES $EXCLUDEFILES \
        2> /tmp/tmp_file; grep "^tar:" /tmp/tmp_file | grep -v "file is unchanged" >> $LOGFILE
TARERROR=$?
/bin/ls -lh $BACKUPPATH/*.tar.gz | awk '{ print $5 " " $8}'						>> $LOGFILE
}

function DIFFBACKUP {
#Timestamp Datei Auslesen
NDATE=$(cat $BACKUPPATH/$BACKUPHOST-timestamp.txt)
echo "DIFF: Backup Files"														>> $LOGFILE
tar czvf $BACKUPPATH/$DIFFBACKUPFILE --newer $NDATE $FILESTOSAVE $OTHERBACKUPFILES $EXCLUDEFILES \
        2> /tmp/tmp_file; grep "^tar:" /tmp/tmp_file | grep -v "file is unchanged" >> $LOGFILE
TARERROR=$?
/bin/ls -lh $BACKUPPATH/*.tar.gz | awk '{ print $5 " " $8}'						>> $LOGFILE
}

function CLEANUP {
rm -f $OTHERBACKUPFILES
}
function ENDBLABLA {
echo ""                                                                 		>> $LOGFILE
echo ""                                                                 		>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
echo "#  $BACKUPHOST Backup							"                      		>> $LOGFILE
echo "#  ended: $(date +"%k:%M %d.%m.%Y") 			"                      		>> $LOGFILE
echo "#############################################	"                    		>> $LOGFILE
}

function RUNNINGTIME {
# Sekundenzähler stoppen ########################################
ende=$(date +%s)

diff=$[ende-anfang]
echo -e "\n"
RUNTIME="Runtime: $[$diff / 60]min $[$diff % 60]s"
}

function MAIL {
mail -s "$BACKUPHOST System-Backup" $MAILADRESS  								< $LOGFILE
}

function NAGIOSRUNNING {
        MESSAGE="RUNNING: Backup is still running"
        echo "$(date +%Y%m%d%H%M) $MESSAGE" > $NAGIOSLOGFILE
}

function NAGIOS {
ERRORS=$[$DELETEERROR+$PACKAGELISTERROR+$INSTALLERANSWERSERROR+$PACKAGEANSWERSERROR+$MYSQLERROR+$GZIPERROR+$TARERROR]
if [ $ERRORS = 0 ]; then 
	MESSAGE="SUCCESS: Backup runs well! - $RUNTIME"
elif [ $DELETEERROR != 0 ]; then
	MESSAGE="ERROR: Problems at Delete Job - Errorcode: $DELETEERROR - $RUNTIME"
elif [ $PACKAGELISTERROR != 0 ]; then
	MESSAGE="ERROR: Problems at Packagelist Job - Errorcode: $PACKAGELISTERROR - $RUNTIME"
elif [ $INSTALLERANSWERSERROR != 0 ]; then
	MESSAGE="ERROR: Problems at InstallAnswers Job - Errorcode: $INSTALLERANSWERSERROR - $RUNTIME"
elif [ $MYSQLERROR != 0 ]; then
	MESSAGE="ERROR: Problems at MySQL Job - Errorcode: $MYSQLERROR - $RUNTIME"
elif [ $GZIPERROR != 0 ]; then
	MESSAGE="ERROR: Problems at GZIP Job - Errorcode: $GZIPERROR - $RUNTIME"
elif [ $TARERROR != 0 ]; then
	MESSAGE="ERROR: Problems at TAR Backup Job - Errorcode: $TARERROR - $RUNTIME"
else
    MESSAGE="UNKNOWN: Other Error"
fi
echo "$(date +%Y%m%d%H%M) $MESSAGE" 												> $NAGIOSLOGFILE
}

#####################################################################################
# All functions into 1 function :-)
#####################################################################################

function SYSTEMBACKUP {
# Sekundenzähler starten ########################################
anfang=$(date +%s)

if [ $NAGIOSMONITORING = yes ]; then
        NAGIOSRUNNING
fi

STARTBLABLA
BACKUPDIRCHECK
REMOVE
PACKAGE
if [ $MYSQLACTIVE = yes ]; then
	MYSQL
elif [ $MYSQLACTIVE = no ]; then
	MYSQLERROR="0"	
fi
if [ ! -f $BACKUPPATH/$BACKUPHOST-timestamp.txt ]; then 
	FULLBACKUP 																
elif [ -f $BACKUPPATH/$BACKUPHOST-timestamp.txt ]; then
	DIFFBACKUP 												
fi
CLEANUP
ENDBLABLA
RUNNINGTIME
if [ $STATUSMAIL = yes ]; then
    MAIL
fi
if [ $NAGIOSMONITORING = yes ]; then
    NAGIOS
fi
}

#####################################################################################
# Check for configfiles
#####################################################################################

if [ $USECONFIGS = yes ]; then
	for i in $(find $CONFIGFILEPATH -name "*.conf"); do
		source $i
		SYSTEMBACKUP
	done
else
	SYSTEMBACKUP
fi
