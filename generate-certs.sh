#!/usr/bin/env bash
#########################################################################
#Name: generate-certs.sh
#Subscription: This Script generates ssl certs
##by A. Laub
#andreas[-at-]laub-home.de
#
#License:
#This program is free software: you can redistribute it and/or modify it
#under the terms of the GNU General Public License as published by the
#Free Software Foundation, either version 3 of the License, or (at your option)
#any later version.
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
#or FITNESS FOR A PARTICULAR PURPOSE.
#########################################################################
#Set the language
export LANG="en_US.UTF-8"
#Load the Pathes
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# set the variables

# Just change to your belongings
COMPOSE_PROJECT_DIR="/opt/mosquitto"
IP="laub-raspi4.laub.loc"
SUBJECT_CA="/C=SE/ST=Mannheim/L=Mannheim/O=himinds/OU=CA/CN=$IP"
SUBJECT_SERVER="/C=SE/ST=Mannheim/L=Mannheim/O=himinds/OU=Server/CN=$IP"
SUBJECT_CLIENT="/C=SE/ST=Mannheim/L=Mannheim/O=himinds/OU=Client/CN=$IP"

function generate_CA () {
   echo "$SUBJECT_CA"
   openssl req -x509 -nodes -sha256 -newkey rsa:2048 -subj "$SUBJECT_CA"  -days 3650 -keyout $COMPOSE_PROJECT_DIR/certs/ca.key -out $COMPOSE_PROJECT_DIR/certs/ca.crt
}

function generate_server () {
   echo "$SUBJECT_SERVER"
   openssl req -nodes -sha256 -new -subj "$SUBJECT_SERVER" -keyout $COMPOSE_PROJECT_DIR/certs/server.key -out $COMPOSE_PROJECT_DIR/certs/server.csr
   openssl x509 -req -sha256 -in $COMPOSE_PROJECT_DIR/certs/server.csr -CA $COMPOSE_PROJECT_DIR/certs/ca.crt -CAkey $COMPOSE_PROJECT_DIR/certs/ca.key -CAcreateserial -out $COMPOSE_PROJECT_DIR/certs/server.crt -days 3650
}

function generate_client () {
   echo "$SUBJECT_CLIENT"
   openssl req -new -nodes -sha256 -subj "$SUBJECT_CLIENT" -out $COMPOSE_PROJECT_DIR/certs/client.csr -keyout $COMPOSE_PROJECT_DIR/certs/client.key 
   openssl x509 -req -sha256 -in $COMPOSE_PROJECT_DIR/certs/client.csr -CA $COMPOSE_PROJECT_DIR/certs/ca.crt -CAkey $COMPOSE_PROJECT_DIR/certs/ca.key -CAcreateserial -out $COMPOSE_PROJECT_DIR/certs/client.crt -days 3650
}

function copy_keys_to_broker () {
   cp $COMPOSE_PROJECT_DIR/certs/ca.crt $COMPOSE_PROJECT_DIR/data/mosquitto/conf/certs/
   cp $COMPOSE_PROJECT_DIR/certs/server.crt $COMPOSE_PROJECT_DIR/data/mosquitto/conf/certs/
   cp $COMPOSE_PROJECT_DIR/certs/server.key $COMPOSE_PROJECT_DIR/data/mosquitto/conf/certs/
}

generate_CA
generate_server
generate_client
copy_keys_to_broker
