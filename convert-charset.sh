#!/bin/bash
for i in $(find . -iname "*.php"); do
        iconv -f iso-8859-1 -t UTF-8 $i > $i.bak
        mv $i.bak $i
done
