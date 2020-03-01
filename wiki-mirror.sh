#!/bin/bash
# Dieses Skript erstellt eine 1zu1 Kopie eines Mediawikis auf einem anderen System
# by A.laub andreas@laub-home.de
#Load the Pathes
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

MYSQLDUMPUSER="wikiuser"
MYSQLDUMPPASSWORD="wiki2009!"
DUMPDATABASE="wikidb"
DUMPFILE="/tmp/$DUMPDATABASE.sql.gz"
TARGETHOST="warehouse.she.de"
DUMPTARGET="/tmp/$DUMPDATABASE.sql.gz"
SSHPORT="20002"
WIKIFILES="/srv/httpd/vhosts/www.laub-home.de/*"
TARGETWIKIFILES="/srv/httpd/vhosts/wiki2.laub-home.de/"
LSETTINGS="${TARGETWIKIFILES}htdocs/LocalSettings.php"

# Erstellt den MySQL Dump
mysqldump --databases $DUMPDATABASE -u$MYSQLDUMPUSER -p$MYSQLDUMPPASSWORD | gzip > $DUMPFILE

# Kopiere MySQL Dump
scp -q -P $SSHPORT $DUMPFILE $TARGETHOST:$DUMPTARGET

# Spiele MySQL Dump ein
ssh -p $SSHPORT $TARGETHOST "gunzip < $DUMPTARGET | mysql -u$MYSQLDUMPUSER -p$MYSQLDUMPPASSWORD"

# Sync Vhost Files
rsync --rsh="ssh -p$SSHPORT" --delete -azq --progress --partial --inplace --log-file=/dev/null --bwlimit=50 $WIKIFILES $TARGETHOST:$TARGETWIKIFILES

# Wiki auf ReadOnly stellen:
ssh -p $SSHPORT $TARGETHOST "sed -i -e s/'^#\$wgReadOnly'/'\$wgReadOnly'/g $LSETTINGS"

# Aufraeumen:
rm -f $DUMPFILE
