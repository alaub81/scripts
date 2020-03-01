#!/bin/bash
SUCHEN="www.domain1.de"
ERSETZEN="www.domain2.de"
INORDNER="/var/log/httpd/"

cd $INORDNER
for i in $(find . -iname "*$SUCHEN*" | awk -F './' '{print $2}'); do
        mv $i $(echo $i| sed s/$SUCHEN/$ERSETZEN/g)
done
