from time import sleep
from scapy.layers.inet import Ether, IP, UDP
from scapy.layers.rip import RIPEntry, RIP
from scapy.all import send
import sys
import struct
import time

MAC_TESTER1 = '00:e0:4c:68:3c:b7'
IP_TESTER1 = '10.0.1.2'
IP_RIP = '10.0.0.1'
IFACE = "enx00e04c683cb7"
for i in range(100, 110):
    send(IP(dst=IP_RIP, ttl=64) /
         UDP() /
         RIP(cmd=2, version=2) /
         RIPEntry(addr='%d.140.1.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.2.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.3.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.4.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.5.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.6.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.140.7.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.140.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.141.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.142.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.143.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.144.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.145.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.146.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.147.0.0' % i, mask='255.255.0.0'),
         iface=IFACE)
    time.sleep(0.1)
