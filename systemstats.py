#!/usr/bin/python3
from gpiozero import CPUTemperature
import psutil
import datetime

# do the stuff
uptime = datetime.datetime.now() - datetime.datetime.fromtimestamp(psutil.boot_time())
uptime_min = (uptime.seconds+uptime.days*24*3600)/60

cpu_temp = CPUTemperature()

cpu_usage = psutil.cpu_percent(interval=1, percpu=False)

load_1, load_5, load_15 = psutil.getloadavg()

ram = psutil.virtual_memory()
ram_total = ram.total / 2**20       # MiB.
ram_used = ram.used / 2**20
ram_free = ram.free / 2**20
ram_percent_used = ram.percent

disk = psutil.disk_usage('/')
disk_total = disk.total / 2**30     # GiB.
disk_used = disk.used / 2**30
disk_free = disk.free / 2**30
disk_percent_used = disk.percent

print("---System Informations---")
print("System Uptime: %s - %.0f min" % (uptime, uptime_min))
print("CPU Temperatur: {:.1f}".format(cpu_temp.temperature) + " °C")
print("CPU Usage: {:.0f} %".format(cpu_usage))
print("Load average: %.2f %.2f %.2f" % (load_1, load_5, load_15))
print("Ram Total: %.1f MiB\nRam Used: %.1f MiB\nRam Free: %.1f MiB\nRam Usage: %.1f %%" % (ram_total, ram_used, ram_free, ram_percent_used))
print("Disk Total: %.1f GiB\nDisk Used: %.1f GiB\nDisk Free: %.1f GiB\nDisk Usage: %.1f %%" % (disk_total, disk_used, disk_free, disk_percent_used))
