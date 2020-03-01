#!/usr/bin/env bash
#########################################################################
#Name: clone-docker-volumes.sh
#Subscription: that sctipt clones docker volumes - Source to Destination.
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

#do the stuff
if [ "$1" = "" -o "$2" = "" ]; then
        echo -e "Usage: ${0} { SourceVolumeName } { DestinationVolumeName }\n"
	echo -e '  use: "docker volume ls"\n  for a list of all available docker volume names\n'
        exit
fi

# check if Volumes existing
docker volume inspect $1 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source volume \"$1\" does not exist"
        exit
fi
docker volume inspect $2 > /dev/null 2>&1

if [ "$?" != "0" ]
then
        echo "The destination volume \"$2\" does not exist"
	while true; do
    		read -p "Would you like to create it? " yn
    		case $yn in
        		[Yy]* ) echo "Creating destination volume \"$2\"...";docker volume create --name $2;break;;
        		[Nn]* ) exit;;
        		* ) echo "Please answer yes or no.";;
    		esac
	done
fi
# copy the stuff
echo "Copying data from source volume \"$1\" to destination volume \"$2\"..."
docker run --rm \
	   --name clonevolume
           -i \
           -t \
           -v $1:/from:ro \
           -v $2:/to \
           alpine ash -c "cd /from ; cp -av . /to"
echo "Done copying data from source volume \"$1\" to destination volume \"$2\""
