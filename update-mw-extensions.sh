#!/bin/bash
#########################################################################
#Name: update-mw-extensions.sh
#Subscription: Updates all MediaWiki extensions which are installed via GIT
#		It can also be used with a docker compose project.
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

# Automatically Restart the compose Project after Upgrade?
# true or false
RESTART=false

# where to find compose Project
#COMPOSEPROJECT=/opt/laubhome_135
COMPOSEPROJECT=$(pwd)

# where to find the extensions outgoing of the script Path
EXTENSIONSDIR=$COMPOSEPROJECT/data/extensions

### Do the stuff
for i in $(ls $EXTENSIONSDIR); do
	if [ -d $EXTENSIONSDIR/$i/.git ]; then
		echo -e "\n$i ist ein GIT Repository:"
#                cd $EXTENSIONSDIR/$i && git pull
		git -C $EXTENSIONSDIR/$i pull
	fi
done

# At the End restart of the compose project
if [ $RESTART = true ]; then
	echo -e "\nRestarting the compose project!"
	cd $COMPOSEPROJECT
	docker-compose restart
elif [ $RESTART = false ]; then
	echo -e "\nDon't restarting the compose project!"
fi
