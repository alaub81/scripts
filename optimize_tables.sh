#!/bin/bash

# Change these variables to reflect your situation.
dbhost="localhost"
sqluser="root"
password="kmyeser145"

/usr/bin/mysqlcheck -u$sqluser -p$password -h$dbhost --auto-repair --optimize --all-databases >/dev/null
