#!/bin/bash
#########################################################################
#Name: mysql-backup.sh
#Subscription: This script makes a mysql backup, it can save individual
#              db dumps, a full dump and/or delete older files. Each of
#              this three processes can be en- or disabled in the config
#              file (see the variables my_config_folder and my_config_file)
#Version: 1.0
#
#by Simon Skolik simon.skolik@she.net
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

### source the config file ###
my_config_folder="/etc"
my_config_file="$my_config_folder/mysqldump.conf"

if [ ! -f "$my_config_file" ]; then
	echo "Konfigurationsdatei unter $my_config_folder nicht gefunden, abbruch..."
	exit 1
else
	source "$my_config_file"
fi
 
### error variables ###
my_mysql_error=0
my_gzip_error=0
my_find_error=0

### create backup folder ###
if [ ! -d "$my_backup_folder" ]; then
	mkdir -p "$my_backup_folder"
fi

### create backup folder (single file per db) ###
if [ ! -d "$my_backup_single_db_folder" ] && [ "$my_single_db_per_file" == "enabled" ]; then
	mkdir -p "$my_backup_single_db_folder"
fi

### functions ###

### create the individual database files ###
function _create_single_file_per_db_backup() {
	# get all db names
	my_mysql_databases="$(mysql --user="$my_mysql_user" --password="$my_mysql_password" -Bse 'SHOW DATABASES;' | tail -n +2 | sed -e 's/performance_schema//g')"

	# create the db sql files
	for i in $my_mysql_databases; do
		echo -n "Creating MySQL dump of database '$i': "
		mysqldump --user="$my_mysql_user" --password="$my_mysql_password" $my_mysql_additional_parameters "$i" | gzip > "$my_backup_single_db_folder/$i.sql.gz"
		my_mysql_error=$?
		if [ $my_mysql_error -ne 0 ]; then
			echo "ERROR: MySQL exit code: $my_mysql_error; gzip exit code: $my_gzip_error"
		else
			echo "Done"
		fi
	done
}

### create the full mysql dump ###
function _create_full_dump() {
	echo -n "Creating full MySQL dump: "
	mysqldump --user="$my_mysql_user" --password="$my_mysql_password" $my_mysql_additional_parameters --all-databases | gzip > "$my_backup_folder/$my_backup_name.sql.gz"
	my_mysql_error=$?
	if [ $my_mysql_error -ne 0 ]; then
		echo "ERROR: MySQL exit code: $my_mysql_error; gzip exit code: $my_gzip_error"
	else
		echo "Done"
	fi
}

### delete old files ###
function _delete_old_files(){
	echo ""
	echo "Deleting files older then $my_backup_ttl day(s):"
	find "$my_backup_folder/" -mtime +$my_backup_ttl -print -delete
	my_find_error=$?
	if [ $my_find_error -ne 0 ]; then
		echo "ERROR: find exit code: $my_find_error"
	else
		echo "Done"
	fi
}

### main ###
echo "========== Start MySQL-Backup: $(date) =========="
if [ "$my_single_db_per_file" == "enabled" ]; then
	_create_single_file_per_db_backup
fi

if [ "$my_full_dump" == "enabled" ]; then
	_create_full_dump
fi

if [ "$my_delete_old_files" == "enabled" ]; then
	_delete_old_files
fi

echo ""
echo "Current files in backup folder:"
ls -lhR "$my_backup_folder"
echo "========== End MySQL-Backup: $(date) ============"
