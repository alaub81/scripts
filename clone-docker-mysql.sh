#!/usr/bin/env bash
#########################################################################
#Name: clone-docker-mysql.sh
#Subscription: This Script copies MySQL DB from Container A to Container B
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

### Do the stuff
if [ "$1" = "" -o "$2" = "" ]; then
         echo -e "Usage: ${0} { SourceMySQLContainer } { DestinationMySQLContainer }\n"
         echo -e '  use: "docker ps"\n  for a list of all available docker container\n'
         exit
fi

docker container inspect $1 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source database container \"$1\" does not exist"
        exit
fi
docker container inspect $2 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source database container \"$2\" does not exist"
        exit
fi

# copy the database
MYSQL_DATABASE=$(docker exec $1 env | grep -E '^(MYSQL|MARIADB)_DATABASE=' |cut -d"=" -f2)
SOURCE_MYSQL_PWD=$(docker exec $1 env | grep -E '^(MYSQL|MARIADB)_ROOT_PASSWORD=' |cut -d"=" -f2)
DEST_MYSQL_PWD=$(docker exec $2 env | grep -E '^(MYSQL|MARIADB)_ROOT_PASSWORD=' |cut -d"=" -f2)
echo -e " * Copying $MYSQL_DATABASE DB from $1 to $2 ...";
if docker exec -it $1 test -e /usr/bin/mysqldump; then
        docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$SOURCE_MYSQL_PWD \
                $1 /usr/bin/mysqldump -u root $MYSQL_DATABASE |\
        docker exec -i -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$DEST_MYSQL_PWD \
                $2 /usr/bin/mysql -u root $MYSQL_DATABASE
elif docker exec -it $1 test -e /usr/bin/mariadb-dump; then
        docker exec -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$SOURCE_MYSQL_PWD \
                $1 /usr/bin/mariadb-dump -u root $MYSQL_DATABASE |\
        docker exec -i -e MYSQL_DATABASE=$MYSQL_DATABASE -e MYSQL_PWD=$DEST_MYSQL_PWD \
                $2 /usr/bin/mariadb -u root $MYSQL_DATABASE
else
        echo " ERROR: cannot find dump command for container $1!"
fi