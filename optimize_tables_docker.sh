#!/usr/bin/env bash
#########################################################################
#Name: optimize_tables_docker.sh
#Subscription: This Script optimizes databases in 
#docker mysql or mariadb containers,
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

# Which Container databases do you want to optimze?
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
echo -e " Optimize Database in Container:";
for i in $CONTAINER; do
	MYSQL_PWD=$(docker exec $i env | grep MYSQL_ROOT_PASSWORD |cut -d"=" -f2)
	echo -e "  * $i";
	docker exec -e MYSQL_PWD=$MYSQL_PWD \
		$i /usr/bin/mysqlcheck -u root --auto-repair --optimize --all-databases >/dev/null
done
echo -e "Optimize Databases completed\n" 



