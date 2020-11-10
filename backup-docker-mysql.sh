#!/usr/bin/env bash
#########################################################################
#Name: backup-docker-mysql.sh
#Subscription: This Script backups docker mysql or mariadb containers,
#or better dumps their database to a backup directory
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

# Where to store the Backup files?
BACKUPDIR=/backup/database

# How many Days should a backup be available?
DAYS=2

# Timestamp definition for the backupfiles (example: $(date +"%Y%m%d%H%M") = 20200124-2034)
TIMESTAMP=$(date +"%Y%m%d%H%M")

# Which Containers do you want to backup?
# Container names separated by space
#CONTAINER="mysqlcontainer 1 mysqlcontainer2 mysqlcontainer3"
# you can use "$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1)"
# for all containers which are using mysql or mariadb images
#CONTAINER=$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1)
# you can filter all containers with grep (include only) or grep -v (exclude) or a combination of both
# to do a filter for 2 or more arguments separate them with "\|"
# example: $(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1 | grep -v 'container1\|container2')
#CONTAINER=$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1 | grep -v 'container1\|container2')
CONTAINER=$(docker ps --format '{{.Names}}:{{.Image}}' | grep 'mysql\|mariadb' | cut -d":" -f1 |grep -v 'mailcowdockerized')


### Do the stuff
echo -e "Start $TIMESTAMP Backup for Databases: \n"
if [ ! -d $BACKUPDIR ]; then
	mkdir -p $BACKUPDIR
fi

for i in $CONTAINER; do
	MYSQL_DATABASE=$(docker exec $i env | grep MYSQL_DATABASE |cut -d"=" -f2)
	MYSQL_PWD=$(docker exec $i env | grep MYSQL_ROOT_PASSWORD |cut -d"=" -f2)
	echo -e " create Backup for Database on Container:\n  * $MYSQL_DATABASE DB on $i";
	docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$MYSQL_PWD \
		$i /usr/bin/mysqldump -u root $MYSQL_DATABASE \
		| gzip > $BACKUPDIR/$i-$MYSQL_DATABASE-$TIMESTAMP.sql.gz
	# dont delete last old backups!
	OLD_BACKUPS=$(ls -1 $BACKUPDIR/$i*.gz |wc -l)
	if [ $OLD_BACKUPS -gt $DAYS ]; then
		find $BACKUPDIR -name "$i*.gz" -daystart -mtime +$DAYS -delete
	fi
done
echo -e "\n$TIMESTAMP Backup for Databases completed\n" 
