#!/bin/bash
# Dieses Skript erstellt eine 1zu1 Kopie eines Mediawikis auf einem anderen System
# by A.laub andreas[-at-]laub-home.de
#Load the Pathes
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

MYSQLDUMPUSER="wikiuser"
MYSQLDUMPPASSWORD="wikipassword"
DUMPDATABASE="wikidb"
TARGETHOST="host.domain.tld"
SSHPORT="22"
WIKIFILES="/srv/httpd/vhosts/wiki.laub-home.de/"
DUMPFILE="/srv/Sicherung/wiki.laub-home.de/$DUMPDATABASE.sql.gz"
BACKUPFILE="/srv/Sicherung/wiki.laub-home.de/wiki.laub-home.de.tar.gz"

# Erstellt den MySQL Dump auf Backup Host
mysqldump --databases $DUMPDATABASE -u$MYSQLDUMPUSER -p$MYSQLDUMPPASSWORD | gzip | ssh -p $SSHPORT -C $TARGETHOST "cat > $DUMPFILE"

# Erstelle Backup File auf Backup Host
cd $WIKIFILES
tar -cf - * | ssh -p $SSHPORT -C $TARGETHOST "cat > $BACKUPFILE"
