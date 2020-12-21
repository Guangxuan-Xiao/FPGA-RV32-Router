from time import sleep
from scapy.layers.inet import Ether, IP, UDP
from scapy.layers.rip import RIPEntry, RIP
from scapy.all import send
import sys
import struct
import time

IPs = ['10.0.0.1', '10.0.1.1', '10.0.2.1', '10.0.3.1']
IFACEs = ["enx00e04c683cb7", "enx00e04c683cb7"]
for i in range(100, 110):
    port = 0
    send(IP(dst=IP_RIPs[port], ttl=64) /
         UDP() /
         RIP(cmd=2, version=2) /
         RIPEntry(addr='%d.1.1.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.2.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.3.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.4.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.5.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.6.0' % i, mask='255.255.255.0') /
         RIPEntry(addr='%d.1.7.0' % i, mask='255.255.255.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         #     RIPEntry(addr='%d.0.0.0' % i, mask='255.0.0.0') /
         RIPEntry(addr='%d.0.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.1.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.2.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.3.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.4.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.5.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.6.0.0' % i, mask='255.255.0.0') /
         RIPEntry(addr='%d.7.0.0' % i, mask='255.255.0.0'))
    time.sleep(1)
