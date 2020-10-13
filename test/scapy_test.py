from scapy.all import *
dst = '187.187.187.0'
while True:
    send(IP(ttl=255, dst=dst), iface="enx000ec650a042")
