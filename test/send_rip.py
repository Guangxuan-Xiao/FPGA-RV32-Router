from scapy.layers.inet import Ether, IP, UDP
from scapy.layers.rip import RIPEntry, RIP
from scapy.all import send
import sys
import struct

MAC_TESTER1 = '00:e0:4c:68:3c:b7'
IP_TESTER1 = '10.0.1.2'
IP_RIP = '10.0.0.1'
IFACE = "enx00e04c683cb7"
for i in range(1):
    send(IP(dst=IP_RIP, ttl=64) /
         UDP() /
         RIP(cmd=2, version=2) /
         #     RIPEntry(addr='140.140.1.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.2.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.3.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.4.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.5.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.6.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.7.0', mask='255.255.255.0') /
         #     RIPEntry(addr='140.140.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.141.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.142.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.143.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.144.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.145.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.146.0.0', mask='255.255.0.0') /
         #     RIPEntry(addr='140.147.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='141.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='142.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='143.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='144.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='145.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='146.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='147.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='148.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='149.0.0.0', mask='255.0.0.0') /
         RIPEntry(addr='140.140.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.141.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.142.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.143.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.144.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.145.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.146.0.0', mask='255.255.0.0') /
         RIPEntry(addr='140.147.0.0', mask='255.255.0.0'),
         iface=IFACE)
#     send(IP(dst=IP_RIP, ttl=64) /
#          UDP() /
#          RIP(cmd=2, version=2) /
#          RIPEntry(addr='150.140.1.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.2.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.3.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.4.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.5.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.6.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.140.7.0', mask='255.255.255.0') /
#          RIPEntry(addr='150.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='151.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='152.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='153.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='154.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='155.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='156.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='157.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='158.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='159.0.0.0', mask='255.0.0.0') /
#          RIPEntry(addr='150.140.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.141.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.142.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.143.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.144.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.145.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.146.0.0', mask='255.255.0.0') /
#          RIPEntry(addr='150.147.0.0', mask='255.255.0.0'), iface=IFACE)
