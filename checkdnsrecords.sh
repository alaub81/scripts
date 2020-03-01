#!/bin/bash
# checkdnsrecords.sh
# by A.Laub andreas[-at-]laub-home.de

DOMAINS="wiki.laub-home.de www.laub-home.de"
MAIL="andreas@laub-home.de"

for i in $DOMAINS; do
if [ -z "$(nslookup $i | grep "server can't find $i")" ]; then
        nslookup $i | mail -s "$i ist angelegt" $MAIL
fi
done
