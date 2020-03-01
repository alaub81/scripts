#!/bin/bash
# oracle-backup.sh
# Oracle Full Dump Skript mit Mail Benachrichtigung
# by A. Laub andreas[-at-]laub-home.de

# Set Variables
ORACLE_BASE=/srv/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.3/dbhome_1
BACKUPDIR=/srv/backup
BACKUPFILE=oracle-full.dmp
ORACLESHELLUSER=oracle
USER=system
PASSWORD=password
DBNAME=TNSALIAS
LOGFILE=oracle-full.log
DPATH="/srv/u01/app/oracle/product/11.2.0/dbhome_1/bin"
MAIL=mail@domain.de

# Delete old Backups
rm -f $BACKUPDIR/$BACKUPFILE.gz


# Run Backup
su - $ORACLESHELLUSER -c "export ORACLE_HOME=$ORACLE_HOME; $DPATH/expdp $USER/$PASSWORD@$DBNAME DIRECTORY=BACKUP_DIR DUMPFILE=$BACKUPFILE FULL=y LOGFILE=$LOGFILE"

# Zippen
gzip $BACKUPDIR/$BACKUPFILE

# Statusmail
if [ -n "$(grep "successfully completed" $BACKUPDIR/$LOGFILE)" ]; then
        mail -s "$(hostname -s) - DB-Dump - $(grep "successfully completed" $BACKUPDIR/$LOGFILE | awk '{print $3" "$4 }')" $MAIL < $BACKUPDIR/$LOGFILE
else
        mail -s "$(hostname -s) - DB-Dump - ERROR" $MAIL < $BACKUPDIR/$LOGFILE
fi

