#!/usr/bin/python3
import Adafruit_DHT

humidity, temperature = Adafruit_DHT.read_retry(Adafruit_DHT.AM2302, 17)
print("%.2f °C  %.2f %%" % (temperature, humidity))
