#!/bin/bash
# Dieses Skript erstellt eine 1zu1 Kopie eines Mediawikis als Teststage in einem anderen vHost
# by A.laub andreas@laub-home.de
#Load the Pathes
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH
 
PRODFOLDER="/srv/httpd/vhosts/www.laub-home.de"
TESTFOLDER="/srv/httpd/vhosts/twiki.laub-home.de"
 
MYSQLDUMPUSER="wikiuser"
MYSQLDUMPPASSWORD="wiki2009!"
PRODDATABASE="wikidb"
TESTDATABASE="wikitestdb"
DUMPFILE="/tmp/dbdump.sql"
 
TESTWIKINAME="Test Laub-Home.de Wiki"
TESTMETANAME="Test_Laub-Home.de_Wiki"
TESTURL="http://twiki.laub-home.de"
 
# Zuerst den vhost Ordner kopieren
if [ -d $TESTFOLDER ]; then
        rm -rf $TESTFOLDER
        echo "$TESTFOLDER deleted"
fi
mkdir -p $TESTFOLDER
echo "$TESTFOLDER created"
cp -rp $PRODFOLDER/* $TESTFOLDER/
echo "Wiki's webfolder copied to teststage"
 
# LocalSettings anpassen
LOCALSETTINGS=$(find $TESTFOLDER -name LocalSettings.php)
for i in $LOCALSETTINGS; do
        sed -i -e 's/'"$PRODDATABASE"'/'"$TESTDATABASE"'/g' $i
        sed -i -e 's/'^\$wgServer'/'#\$wgServer'/g' $i
        sed -i -e 's/'^\$wgSitename'/'#\$wgSitename'/g' $i
        sed -i -e 's/'^\$wgMetaNamespace'/'#\$wgMetaNamespace'/g' $i
        echo "# Rename Wiki" >> $i
        echo "\$wgSitename = \"$TESTWIKINAME\";" >> $i
        echo "\$wgMetaNamespace = \"$TESTMETANAME\";" >> $i
        echo "\$wgServer = \"$TESTURL\";" >> $i
done
echo "LocalSettings configured"
 
# Erstellt den MySQL Dump
mysqldump --add-drop-database --flush-privileges --databases $PRODDATABASE -u$MYSQLDUMPUSER -p$MYSQLDUMPPASSWORD | sed -e 's/'"$PRODDATABASE"'/'"$TESTDATABASE"'/g' > $DUMPFILE
echo 'GRANT ALL PRIVILEGES ON `'$TESTDATABASE'` . * TO '"$MYSQLDUMPUSER"'@'localhost';' >> $DUMPFILE
 
# Spiele MySQL Dump ein
echo "Enter the MySQL root password:"
mysql -uroot -p < $DUMPFILE
echo "Productiondatabase copied into test."
 
# Aufraeumen:
rm -f $DUMPFILE
echo "Finish!"
