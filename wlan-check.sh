#!/usr/bin/env bash
#########################################################################
# Name: wlan-check.sh
# Purpose: Reconnects WLAN if connection to gateway is lost
# Author: A. Laub - andreas[-at-]laub-home.de
#########################################################################

# Sprache & Umgebungsvariablen
export LANG="en_US.UTF-8"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Konfiguration
GATEWAY="192.168.60.1"
LOGFILE="/root/wlancheck.log"
TIMESTAMP=$(date -Is)

# Richtiges Interface ermitteln (ignoriere p2p-Devices)
WLAN_IFACE=$(iw dev | awk '$1=="Interface"{print $2}' | grep -v '^p2p-' | head -n1)

# Falls kein Interface erkannt wurde – Abbruch mit Log
if [ -z "$WLAN_IFACE" ]; then
    echo "$TIMESTAMP Kein gültiges WLAN-Interface gefunden!" >> "$LOGFILE"
    exit 1
fi

# Prüfe, ob mit WLAN verbunden (SSID vorhanden)
SSID=$(iwgetid "$WLAN_IFACE" --raw)

if [ -z "$SSID" ]; then
    echo "$TIMESTAMP Keine SSID verbunden." >> "$LOGFILE"
else
    echo "$TIMESTAMP Verbunden mit SSID: $SSID" >> "$LOGFILE"
fi

# Prüfe Verbindung zum Gateway
ping -I "$WLAN_IFACE" -c 1 -W 5 "$GATEWAY" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "$TIMESTAMP Gateway nicht erreichbar. Reconnect wird durchgeführt..." >> "$LOGFILE"

    # WLAN trennen
    ip link set "$WLAN_IFACE" down
    sleep 2
    ip link set "$WLAN_IFACE" up
    sleep 2

    # Konfiguration neu laden
    wpa_cli -i "$WLAN_IFACE" reconfigure >> "$LOGFILE" 2>&1
    sleep 3

    # Neue IP anfordern
    dhcpcd -n "$WLAN_IFACE" >> "$LOGFILE" 2>&1

    echo "$TIMESTAMP Reconnect-Versuch abgeschlossen." >> "$LOGFILE"
else
    echo "$TIMESTAMP Verbindung zum Gateway OK." >> "$LOGFILE"
fi

