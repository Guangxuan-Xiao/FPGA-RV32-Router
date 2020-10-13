from scapy.all import *
dst = '170.170.170.170'
while True:
    send(IP(ttl=255, dst=dst), iface="enx00e04c680024")
