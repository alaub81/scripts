#!/bin/bash
#########################################################################
#Name: proxy-lasttest.sh
#Subscription: This script makes makes a proxy test
#by N. Vongeheur
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

function usage() {
	echo " Usage:"
	echo "    $(basename $0) -c COUNT -f /Path/to/url_file -h PROXY_HOST -p PROXY_PORT"
	echo ""
	echo "    -c COUNT                How often should the URLs be called"
	echo "    -f /Path/to/url_file    File with target URLs (One per line)"
	echo "    -h PROXY_HOST           Which Proxy to use"
	echo "    -p PROXY_PORT           Proxy Port"
	echo "    -s                      Silent-Mode"
	exit 1
}

while getopts "c:f:p:h:s" opt
do
        case ${opt} in
	c)	COUNT=${OPTARG}
		;;
        f)      URLS=${OPTARG}
		;;
	h)	PROXY_HOST=${OPTARG}
		;;
	p)	PROXY_PORT=${OPTARG}
		;;
	s)	SILENT="-s"
		;;
        *)      usage
		;;
        esac
done

[ -z "$1" ] && usage
#[ -z ${COUNT} -o -z ${URLS} -o -z ${PROXY_HOST} -o -z ${PROXY_PORT} ] && usage
[ -n "${PROXY_HOST}" ] && PROXY_STRING="-x http://${PROXY_HOST}:${PROXY_PORT}"

for ((c=0; c<=${COUNT}; c++))
do
	cat ${URLS} |
	while read url
	do
		CHECK_OUT=$(curl -k ${SILENT} ${PROXY_STRING} ${url} | grep "The domain name does not exist")
		RC=$?
		[ -z "${CHECK_OUT}" -a "${RC}" = 1 -a -z "${SILENT}" ] && echo "${url} wurde erfolgreich aufgerufen"
		[ -n "${CHECK_OUT}" -o "${RC}" != 1 ] && echo "WARNING: ${url} wurde nicht erfolgreich aufgerufen"
		[ -z "${SILENT}" ] &&  echo ""
	done
done
