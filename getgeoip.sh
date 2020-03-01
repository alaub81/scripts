#!/bin/sh
#
# GeoIP Databases Update
# Script Updates GeoIP Databases
# by A.Laub andreas@laub-home.de

GEOIPLOCATION="/usr/local/share/GeoIP"

if [ ! -d $GEOIPLOCATION ]; then
        mkdir -p $GEOIPLOCATION
fi
cd $GEOIPLOCATION
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz
wget http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz
gunzip -f *.gz
chown root.root *.dat
