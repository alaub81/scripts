#!/bin/bash
# File Transfer Sicherungs Script via SFTP
# by A.Laub andreas[-at-]laub-home.de

TIMESTAMP=$(date +%Y-%m-%d_%H:%M)

if [ ! -d /tmp/trans/ ]; then
        mkdir /tmp/trans/
fi

tar -czvf /tmp/trans/export-$TIMESTAMP.tar.gz /srv/export/

echo "cd in" > /tmp/trans/sftpbatch
echo "put /tmp/trans/export-$TIMESTAMP.tar.gz" >> /tmp/trans/sftpbatch
sftp -b /tmp/trans/sftpbatch -o PubkeyAuthentication=yes -o IdentityFile=/root/.ssh/id_dsa user@10.100.10.10

rm -f /tmp/airplustrans/webcontract-export-$TIMESTAMP.tar.gz
