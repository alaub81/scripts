#!/bin/bash
# Skript Laufzeit berechnen
# by A.Laub andreas[-at-]laub-home.de

# Sekundenzaehler starten ########################################
anfang=$(date +%s)

##################################################################
###Skript Aufrufe#################################################
echo "Schlafen für 10s"
sleep 10


##################################################################
# Sekundenzaehler stoppen ########################################
ende=$(date +%s)

# benoetigte Zeit in Sekunden berechnen ##########################
diff=$[ende-anfang]

# Prüfen, ob benoetigte Zeit kleiner als 60 sec ##################
if [ $diff -lt 60 ]; then
	echo -e 'Runtime '$diff' secs'

# Wenn gleich oder groeßer 60 Sekunden, ##########################
# in Minuten und Sekunden umrechnen ##############################
elif [ $diff -ge 60 ]; then
	echo -e 'Runtime '$[$diff / 60] 'min(s) '$[$diff % 60] 'secs'
fi
