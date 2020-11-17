#!/usr/bin/env python3
import ssl, time, random
import paho.mqtt.client as paho

# set the variables
broker='FQDN / IP of Broker'
port=8883
clientid=f'python-mqtt-{random.randint(0, 1000)}'
username='mosquitto'
password='password'
insecure=True
qos=1
retain_message=True

# do the stuff
client=paho.Client(clientid)
client.username_pw_set(username, password)
client.tls_set(cert_reqs=ssl.CERT_NONE) #no client certificate needed
client.tls_insecure_set(insecure)

##### define callback
def on_message(client, userdata, message):
    time.sleep(1)
    print("received message =",str(message.payload.decode("utf-8")))

##### Bind function to callback
client.on_message=on_message
#####
print(clientid,"is connecting to broker",broker, port)
client.connect(broker, port) #connect
client.loop_start() #start loop to process received messages
print("subscribing ")
client.subscribe("house/+") #subscribe to all house topics
time.sleep(4)
print("publishing ")
client.publish("house/bulb1","ON",qos,retain_message) #publish
client.publish("house/bulb2","OFF",qos,retain_message) #publish
client.publish("house/bulb3","NONE",qos,retain_message) #publish
time.sleep(4)
client.disconnect() #disconnect
client.loop_stop() #stop loop
